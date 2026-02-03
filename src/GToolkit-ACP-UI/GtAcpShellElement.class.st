Class {
	#name : 'GtAcpShellElement',
	#superclass : 'BlElement',
	#instVars : [
		'client',
		'session',
		'listElement',
		'inputElement',
		'statusLabel',
		'cancelButton',
		'modeButton',
		'statusBar',
		'permissionContainer',
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

{ #category : 'actions' }
GtAcpShellElement >> cancelPrompt [
	session ifNil: [ ^ self ].
	client cancelSession: session.
	cancelButton visibility: BlVisibility gone.
	statusLabel text: 'Cancelled'
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

{ #category : 'actions' }
GtAcpShellElement >> cycleModes [
	| modes currentIdx nextMode |
	session ifNil: [ ^ self ].
	modes := session availableModes.
	(modes isNil or: [ modes isEmpty ]) ifTrue: [ ^ self ].
	currentIdx := modes detectIndex: [ :m | (m at: 'id') = session currentModeId ] ifNone: [ 0 ].
	nextMode := modes at: (currentIdx \\ modes size + 1).
	client setMode: (nextMode at: 'id') inSession: session 
		do: [ :result |
			session currentModeId: (nextMode at: 'id').
			self enqueueTask: (BlTaskAction new action: [ self updateStatus ]) ]
		onError: [ :err |
			self enqueueTask: (BlTaskAction new action: [ 
				statusLabel text: ('Mode error: ' , err printString) ]) ]
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
	self initializePermissionContainer.
	self initializeInputElement.
	self initializeStatusBar.
	self addChild: listElement as: #list.
	self addChild: permissionContainer as: #permissions.
	self addChild: inputElement as: #input.
	self addChild: statusBar as: #status
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
GtAcpShellElement >> initializePermissionContainer [
	permissionContainer := BlElement new
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself
]

{ #category : 'initialization' }
GtAcpShellElement >> initializeStatusBar [
	statusLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color gray);
		text: 'Disconnected';
		hMatchParent;
		vFitContent.
	cancelButton := BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude;
		label: 'Cancel';
		beSmallSize;
		visibility: BlVisibility gone;
		margin: (BlInsets left: 6);
		action: [ self cancelPrompt ].
	modeButton := BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude;
		label: 'Mode';
		beSmallSize;
		visibility: BlVisibility gone;
		margin: (BlInsets left: 6);
		action: [ self cycleModes ].
	statusBar := BlElement new
		layout: BlLinearLayout horizontal alignCenterLeft;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		addChild: statusLabel;
		addChild: modeButton;
		addChild: cancelButton;
		yourself
]

{ #category : 'initialization' }
GtAcpShellElement >> initializeStatusElement [
	| statusBar |
	statusElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color gray);
		text: 'Disconnected';
		hMatchParent;
		vFitContent.
	cancelButton := BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude;
		label: 'Cancel';
		beSmallSize;
		visibility: BlVisibility gone;
		action: [ self cancelPrompt ].
	statusBar := BlElement new
		layout: BlLinearLayout horizontal alignCenterLeft;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		addChild: statusElement;
		addChild: cancelButton;
		yourself.
	"Replace statusElement reference with the bar for addChild:"
	statusElement := statusBar
]

{ #category : 'updating' }
GtAcpShellElement >> onPermissionRequested: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ self showPendingPermissions ])
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
	cancelButton visibility: BlVisibility visible.
	client 
		prompt: text 
		inSession: session 
		do: [ :result |
			self enqueueTask: (BlTaskAction new action: [ 
				cancelButton visibility: BlVisibility gone.
				self updateMessages.
				self updateStatus ]) ]
		onError: [ :err |
			self enqueueTask: (BlTaskAction new action: [ 
				| errorText |
				cancelButton visibility: BlVisibility gone.
				errorText := err ifNil: [ 'Connection lost' ]
					ifNotNil: [
						(err isKindOf: Dictionary)
							ifTrue: [ (err at: 'error' ifAbsent: [ err ]) printString ]
							ifFalse: [ err printString ] ].
				statusLabel text: ('Error: ', errorText).
				self updateMessages ]) ]
]

{ #category : 'accessing' }
GtAcpShellElement >> session [
	^ session
]

{ #category : 'updating' }
GtAcpShellElement >> showPendingPermissions [
	| pending |
	permissionContainer removeChildren.
	pending := (session pendingPermissions ifNil: [ #() ]) 
		select: [ :req | (req at: 'status' ifAbsent: [ '' ]) = 'pending' ].
	pending do: [ :req |
		| element |
		element := GtAcpPermissionElement new
			request: req client: client session: session.
		permissionContainer addChild: element ]
]

{ #category : 'subscriptions' }
GtAcpShellElement >> subscribeToSession [
	session announcer
		when: GtAcpSessionUpdated
		send: #onSessionUpdated:
		to: self.
	session announcer
		when: GtAcpPermissionRequested
		send: #onPermissionRequested:
		to: self
]

{ #category : 'private' }
GtAcpShellElement >> updateMessages [
	| msgs |
	msgs := session messages.
	listElement items: msgs.
	msgs ifNotEmpty: [ listElement scrollToItem: msgs last ]
]

{ #category : 'updating' }
GtAcpShellElement >> updateStatus [
	| text |
	text := session 
		ifNil: [ 'Disconnected' ]
		ifNotNil: [ 
			String streamContents: [ :s |
				s nextPutAll: session cwd.
				s nextPutAll: ' | '.
				s nextPutAll: (session sessionId copyFrom: 1 to: 8).
				s nextPutAll: '...'.
				session messages ifNotEmpty: [
					s nextPutAll: ' | '.
					s print: session messages size.
					s nextPutAll: ' msgs' ] ] ].
	statusLabel text: text.
	session ifNotNil: [
		| modes |
		modes := session availableModes.
		(modes notNil and: [ modes notEmpty ])
			ifTrue: [
				modeButton visibility: BlVisibility visible.
				modeButton label: (session currentModeId ifNil: [ 'Mode' ]) ]
			ifFalse: [ modeButton visibility: BlVisibility gone ] ]
]
