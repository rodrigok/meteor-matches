Meteor.publish 'scoreRequests', ->
	return ScoreRequests.find()

Meteor.publish 'matches', ->
	return Matches.find()

Meteor.publish 'users', ->
	return Meteor.users.find()
