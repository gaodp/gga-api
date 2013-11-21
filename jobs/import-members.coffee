# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

await = require 'await'
soap = require 'soap'
ObjectId = require('mongodb').ObjectID
membersSvcUri = "./wsdl/Members.svc.xml"

# Data returned by node-soap that was nil in the output is represented
# as an empty object for some reason...
stringOrUndefined = (input) ->
  if typeof input == 'string'
    input
  else
    null

eliminateUndefineds = (obj) ->
  for key, val of obj
    if typeof val == 'undefined' || val == null
      delete obj[key]
    else if typeof val == 'object'
      if Object.getOwnPropertyNames(val).length == 0
        delete obj[key]

  obj

addressFrom = (address) ->
  composedAddress =
    city: stringOrUndefined(address.City),
    email: stringOrUndefined(address.Email),
    fax: stringOrUndefined(address.Fax),
    phone: stringOrUndefined(address.Phone),
    state: stringOrUndefined(address.State),
    street: stringOrUndefined(address.Street),
    zip: stringOrUndefined(address.Zip)

  eliminateUndefineds(composedAddress)

typeForDistrict = (district) ->
  if district.Type == "House"
    "representative"
  else if district.Type == "Senate"
    "senator"
  else
    console.error("Got an unknown district type: " + district.Type)
    "unknown"

photoUriForMember = (assemblyId, member) ->
  baseUri = if member.type == "representative"
    "http://www.house.ga.gov/SiteCollectionImages/"
  else
    "http://www.senate.ga.gov/SiteCollectionImages/"

  baseUri + member.lastName + member.firstName + assemblyId + ".jpg"

persistMember = (session, member, db, callback) ->
  assemblyIdForMember = Number(member.Id)

  memberDetails =
    type: typeForDistrict(member.District),
    firstName: stringOrUndefined(member.Name.First),
    middleName: stringOrUndefined(member.Name.Middle),
    lastName: stringOrUndefined(member.Name.Last),
    nickname: stringOrUndefined(member.Name.Nickname),
    party: member.Party.substr(0, 1),
    district: Number(member.District.Number)
    city: stringOrUndefined(member.District.Coverage),
    districtAddress: addressFrom member.DistrictAddress

  memberDetails.photoUri = photoUriForMember(assemblyIdForMember, memberDetails)
  memberDetails = eliminateUndefineds(memberDetails)

  db.collection("members").update
    assemblyId: assemblyIdForMember
  ,
    "$set": memberDetails,
    "$addToSet":
      "sessions": session._id
  ,
    upsert: true,
    safe: true
  , (err, doc) ->
    callback(err)

module.exports = (jobs, db) -> soap.createClient membersSvcUri, (err, client) ->
  throw err if err

  jobs.process 'persist member', 20, (job, callback) ->
    # Ensure object IDs are in the correct format.
    job.data.session._id = new ObjectId(job.data.session._id)

    persistMember(job.data.session, job.data.member, db, callback)

  jobs.process 'import member', 20, (job, callback) ->
    callback("Individual member import not currently supported.")

  jobs.process 'import all members for session', 5, (job, callback) ->
    getMembersArgs =
      SessionId: job.data.session.assemblyId

    client.MemberService.BasicHttpBinding_MemberFinder.GetMembersBySession getMembersArgs, (err, result, raw) ->
      if err
        callback(err)
      else
        members = result.GetMembersBySessionResult.MemberListing

        members.map (member) ->
          jobs.create('persist member', member: member, session: job.data.session).save()

        callback()

  jobs.process 'import members', (job, callback) ->
    db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
      results.forEach (session) ->
        job.log "Kueing up import members for session job for " + session._id
        jobs.create('import all members for session', session: session).save()

      callback()
