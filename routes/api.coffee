# Serve JSON to our AngularJS client
Linkedin = require '../modules/linkedin'

linkedin = new Linkedin(
  process.env.LINKEDIN_API_KEY,
  process.env.LINKEDIN_API_SECRET
  process.env.LINKEDIN_USER_TOKEN
  process.env.LINKEDIN_USER_SECRET)

module.exports = exports =
  members: (req, res) ->
    if req.params.id?
      linkedin.get "http://api.linkedin.com/v1/people/id=#{req.params.id}:(email-address,summary,public-profile-url,primary-twitter-account)?format=json", (err, data) ->
        console.log err if err
        res.json data: JSON.parse(data)
    linkedin.get 'http://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,picture-url,headline),num-results)?company-name=cobig-&count=25&format=json', (err, data) =>
      console.log err if err
      res.json data: JSON.parse(data).people.values