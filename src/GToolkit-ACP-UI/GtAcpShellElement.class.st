Class {
	#name : 'GtAcpShellElement',
	#superclass : 'BlElement',
	#instVars : [
		'client',
		'session',
		'listElement',
		'inputElement',
		'statusElement',
		'subscriber'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'instance creation' }
GtAcpShellElement class >> on: aClient session: aSession [
	^ self new
		client: aClient session: aSession;
		yourself
]

{ #category : 'accessing' }
GtAcpShellElement >> client [
	^ client
]

{ #category : 'accessing' }
GtAcpShellElement >> client: aGtAcpClient session: aGtAcpSession [
	client := aGtAcpClient.
	session := aGtAcpSession.
	self subscribeToSession.
	self updateStatus.
	self updateMessages
]

{ #category : 'initialization' }
GtAcpShellElement >> initialize [
	super initialize.
	subscriber := Object new.
	self layout: BlLinearLayout vertical.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].
	self padding: (BlInsets all: 5).
	self initializeListElement.
	self initializeInputElement.
	self initializeStatusElement.
	self addChild: listElement as: #list.
	self addChild: inputElement as: #input.
	self addChild: statusElement as: #status
]

{ #category : 'initialization' }
GtAcpShellElement >> initializeInputElement [
	inputElement := BrEditor new
		hMatchParent;
		vFitContentLimited;
		padding: (BlInsets all: 8);
		border: (BlBorder paint: BrGlamorousColors lightBorderColor width: 1);
		aptitude: BrGlamorousRegularEditorAptitude;
		addShortcut: (BrEditorShortcut new
			name: 'Send message';
			combination: BlKeyCombination primaryReturn;
			performBlock: [ :editor | self sendMessage ];
			yourself)
]

{ #category : 'initialization' }
GtAcpShellElement >> initializeListElement [
	listElement := BrSimpleList vertical
		hMatchParent;
		vMatchParent;
		padding: (BlInsets all: 5);
		itemStencil: [ GtAcpMessageElement new ];
		itemDataBinder: [ :element :msg | element message: msg ]
]

{ #category : 'initialization' }
GtAcpShellElement >> initializeStatusElement [
	statusElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color gray);
		text: 'Disconnected';
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8)
]

{ #category : 'updating' }
GtAcpShellElement >> onSessionUpdated: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ 
		self updateMessages.
		self updateStatus ])
]

{ #category : 'actions' }
GtAcpShellElement >> sendMessage [
	| text |
	session ifNil: [ ^ self ].
	text := inputElement text asString trimBoth.
	text ifEmpty: [ ^ self ].
	inputElement text: '' asRopedText.
	self updateMessages.
	client 
		prompt: text 
		inSession: session 
		do: [ :result |
			self enqueueTask: (BlTaskAction new action: [ 
				self updateMessages.
				self updateStatus ]) ]
		onError: [ :err |
			self enqueueTask: (BlTaskAction new action: [ 
				statusElement text: ('Error: ', err printString) ]) ]
]

{ #category : 'accessing' }
GtAcpShellElement >> session [
	^ session
]

{ #category : 'subscriptions' }
GtAcpShellElement >> subscribeToSession [
	session announcer
		when: GtAcpSessionUpdated
		send: #onSessionUpdated:
		to: self
]

{ #category : 'updating' }
GtAcpShellElement >> updateMessages [
	listElement items: session messages.
	session messages ifNotEmpty: [ 
		listElement scrollToItem: session messages last ]
]

{ #category : 'updating' }
GtAcpShellElement >> updateStatus [
	| text |
	text := session 
		ifNil: [ 'Disconnected' ]
		ifNotNil: [ 
			String streamContents: [ :s |
				s nextPutAll: 'Session: '.
				s nextPutAll: (session sessionId copyFrom: 1 to: 8).
				s nextPutAll: '...'.
				session messages ifNotEmpty: [
					s nextPutAll: ' | '.
					s print: session messages size.
					s nextPutAll: ' messages' ].
				session currentModeId ifNotNil: [ :mode |
					s nextPutAll: ' | Mode: '.
					s nextPutAll: mode ] ] ].
	statusElement text: text
]
