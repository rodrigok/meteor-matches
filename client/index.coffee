Meteor.subscribe 'users'
Meteor.subscribe 'matches'
Meteor.subscribe 'scoreRequests'

Avatar.options =
	fallbackType: 'initials'

Blaze.registerHelper 'arrayify', (obj) ->
	arr = []
	for k, v of obj
		arr.push
			key: k
			value: v
	return arr

Blaze.registerHelper 'getAt', (arr, index) ->
	return arr[index]

Session.setDefault('teams', {})

Template.login.events
	'keydown input.username': (e) ->
		if e.keyCode is 13
			Meteor.call 'updateUserName', e.currentTarget.value
