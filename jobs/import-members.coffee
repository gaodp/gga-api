#    galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
#    Copyright (C) 2013 Matthew Farmer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
MongoClient = require('mongodb').MongoClient
mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

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
  assemblyIdForMember = member.Id

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
    ifSuccessful err, callback, ->
      callback()

module.exports = (jobs, db) ->
  jobs.process 'import members', (job, callback) ->
    soap.createClient membersSvcUri, (err, client) -> ifSuccessful err, callback, ->
      db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
        results.forEach (session) ->
          getMembersArgs =
            SessionId: session.assemblyId

          client.MemberService.BasicHttpBinding_MemberFinder.GetMembersBySession getMembersArgs, (err, result, raw) -> ifSuccessful err, callback, ->
            result.GetMembersBySessionResult.MemberListing.forEach (member) ->
              persistMember session, member, db, callback

            callback()
