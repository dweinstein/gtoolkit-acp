Class {
	#name : 'GtAcpClient',
	#superclass : 'Object',
	#instVars : [
		'transport',
		'sessions',
		'announcer',
		'agentInfo',
		'createdAt'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'accessing' }
GtAcpClient >> agentInfo [
	^ agentInfo
]

{ #category : 'accessing' }
GtAcpClient >> agentInfo: aDictionary [
	agentInfo := aDictionary
]

{ #category : 'permissions' }
GtAcpClient >> allowAlwaysPermission: aRequestId [
	transport respondTo: aRequestId result: (Dictionary new
		at: 'outcome' put: (Dictionary new 
			at: 'outcome' put: 'selected'; 
			at: 'optionId' put: 'allow_always'; 
			yourself);
		yourself)
]

{ #category : 'permissions' }
GtAcpClient >> allowPermission: aRequestId [
	transport respondTo: aRequestId result: (Dictionary new
		at: 'outcome' put: (Dictionary new 
			at: 'outcome' put: 'selected'; 
			at: 'optionId' put: 'allow'; 
			yourself);
		yourself)
]

{ #category : 'protocol' }
GtAcpClient >> allowPermissionRequest: aRequestId optionId: anOptionId [
	transport respondTo: aRequestId result: (Dictionary new
		at: 'outcome' put: (Dictionary new 
			at: 'outcome' put: 'selected'; 
			at: 'optionId' put: anOptionId; 
			yourself);
		yourself)
]

{ #category : 'accessing' }
GtAcpClient >> announcer [
	^ announcer
]

{ #category : 'session management' }
GtAcpClient >> cancelSession: aSession [
	transport
		sendNotification: 'session/cancel'
		params: (Dictionary new 
			at: 'sessionId' put: aSession sessionId; 
			yourself)
]

{ #category : 'lifecycle' }
GtAcpClient >> connectTo: programPath [
	^ self connectTo: programPath args: #()
]

{ #category : 'connecting' }
GtAcpClient >> connectTo: programPath args: anArray [
	transport := GtAcpTransport on: programPath args: anArray.
	transport onExit: [ announcer announce: GtAcpClientUpdated new ].
	self registerHandlers.
	transport start
]

{ #category : 'accessing' }
GtAcpClient >> createdAt [
	^ createdAt ifNil: [ DateAndTime epoch ]
]

{ #category : 'connecting' }
GtAcpClient >> disconnect [
	transport ifNotNil: [ transport terminate ].
	announcer announce: GtAcpClientUpdated new
]

{ #category : 'actions' }
GtAcpClient >> gtDisconnectActionFor: anAction [
	<gtAction>
	self isConnected ifFalse: [ ^ anAction noAction ].
	^ anAction button
		tooltip: 'Disconnect';
		icon: BrGlamorousVectorIcons cancel;
		action: [ :aButton | self disconnect ]
]

{ #category : 'actions' }
GtAcpClient >> gtNewSessionActionFor: anAction [
	<gtAction>
	^ anAction dropdown
		tooltip: 'New session';
		icon: BrGlamorousVectorIcons add;
		content: [ :aButton |
			| items |
			items := OrderedCollection new.
			GtAcpClientRegistry uniqueInstance recentCwds do: [ :aCwd |
				items add: (aCwd -> [ :e |
					self newSessionIn: aCwd do: [ :session |
						e enqueueTask: (BlTaskAction new action: [
							e phlow spawnObject: session ]) ]
					onError: [ :err |
						e enqueueTask: (BlTaskAction new action: [
							e phlow spawnObject: ('Session error: ', err printString) ]) ].
					e fireEvent: BrDropdownHideWish new ]) ].
			items add: ('Browse...' -> [ :e |
				e fireEvent: BrDropdownHideWish new.
				e phlow spawnObject: GtClaudeCodeClient defaultCwd asFileReference ]).
			BrGlamorousSimpleContextMenuContent new
				items: items;
				yourself ]
]

{ #category : 'actions' }
GtAcpClient >> gtRemoveActionFor: anAction [
	<gtAction>
	^ anAction button
		tooltip: 'Remove from registry';
		icon: BrGlamorousVectorIcons close;
		action: [ :aButton | GtAcpClientRegistry uniqueInstance unregister: self ]
]

{ #category : 'gt views' }
GtAcpClient >> gtSessionsFor: aView [
	<gtView>
	^ aView list
		title: 'Sessions';
		priority: 1;
		items: [ sessions values ]
]

{ #category : 'gt views' }
GtAcpClient >> gtTrafficFor: aView [
	<gtView>
	^ transport 
		ifNil: [ aView empty ]
		ifNotNil: [ transport gtTrafficFor: aView ]
]

{ #category : 'handlers' }
GtAcpClient >> handlePermissionRequest: params requestId: anId [
	| sessionId session request toolTitle |
	sessionId := params at: 'sessionId'.
	session := sessions at: sessionId ifAbsent: [ ^ self ].
	toolTitle := (params at: 'toolCall' ifAbsent: [ Dictionary new ]) at: 'title' ifAbsent: [ '' ].
	request := params copy.
	request at: 'requestId' put: anId.
	request at: 'timestamp' put: DateAndTime now.
	"Auto-allow if tool was previously always-allowed in this session"
	(session alwaysAllowedTools includes: toolTitle)
		ifTrue: [
			request at: 'status' put: 'auto-allowed'.
			session permissionHistory add: request.
			self allowPermissionRequest: anId optionId: 'allow_always' ]
		ifFalse: [
			request at: 'status' put: 'pending'.
			session pendingPermissions add: request.
			session permissionHistory add: request.
			session announcer announce: GtAcpPermissionRequested new ]
]

{ #category : 'private' }
GtAcpClient >> handleSessionUpdate: params [
	| sessionId session |
	sessionId := params at: 'sessionId'.
	session := sessions at: sessionId ifAbsent: [ ^ self ].
	session processUpdate: (params at: 'update').
	announcer announce: GtAcpClientUpdated new
]

{ #category : 'initialization' }
GtAcpClient >> initialize [
	super initialize.
	sessions := Dictionary new.
	announcer := Announcer new.
	createdAt := DateAndTime now.
	GtAcpClientRegistry uniqueInstance register: self
]

{ #category : 'lifecycle' }
GtAcpClient >> initializeDo: aBlock onError: anErrorBlock [
	transport
		sendRequest: 'initialize'
		params: (Dictionary new
			at: 'protocolVersion' put: 1;
			at: 'clientCapabilities' put: Dictionary new;
			yourself)
		do: [ :result |
			agentInfo := result at: 'agentInfo' ifAbsent: [ nil ].
			aBlock cull: result ]
		onError: anErrorBlock
]

{ #category : 'lifecycle' }
GtAcpClient >> isConnected [
	^ transport notNil and: [ transport isRunning ]
]

{ #category : 'protocol' }
GtAcpClient >> newSessionIn: aDirectoryString do: aBlock onError: anErrorBlock [
	transport
		sendRequest: 'session/new'
		params: (Dictionary new
			at: 'cwd' put: aDirectoryString;
			at: 'mcpServers' put: #();
			yourself)
		do: [ :result |
			| session |
			session := GtAcpSession fromResponse: result.
			session cwd: aDirectoryString.
			session client: self.
			sessions at: session sessionId put: session.
			aBlock cull: session ]
		onError: anErrorBlock
]

{ #category : 'printing' }
GtAcpClient >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPut: $(;
		nextPutAll: (self isConnected ifTrue: [ 'connected' ] ifFalse: [ 'disconnected' ]);
		nextPutAll: ' - ';
		print: sessions size;
		nextPutAll: ' sessions';
		nextPut: $)
]

{ #category : 'api' }
GtAcpClient >> prompt: aString inSession: aSession do: aBlock onError: anErrorBlock [
	aSession messages add: (GtAcpMessage user: aString).
	aSession announcer announce: GtAcpSessionUpdated new.
	transport
		sendRequest: 'session/prompt'
		params: (Dictionary new
			at: 'sessionId' put: aSession sessionId;
			at: 'prompt' put: {Dictionary new 
				at: 'type' put: 'text'; 
				at: 'text' put: aString; 
				yourself};
			yourself)
		do: [ :result |
			aSession markCurrentMessageComplete.
			aBlock cull: result ]
		onError: anErrorBlock
]

{ #category : 'lifecycle' }
GtAcpClient >> registerHandlers [
	transport on: 'session/update' do: [ :params | self handleSessionUpdate: params ].
	transport on: 'session/request_permission' do: [ :params :fullMessage | 
		self handlePermissionRequest: params requestId: (fullMessage at: 'id') ]
]

{ #category : 'permissions' }
GtAcpClient >> rejectPermission: aRequestId [
	transport respondTo: aRequestId result: (Dictionary new
		at: 'outcome' put: (Dictionary new 
			at: 'outcome' put: 'selected'; 
			at: 'optionId' put: 'reject'; 
			yourself);
		yourself)
]

{ #category : 'accessing' }
GtAcpClient >> sessions [
	^ sessions
]

{ #category : 'session management' }
GtAcpClient >> setMode: aModeId inSession: aSession do: aBlock onError: anErrorBlock [
	transport
		sendRequest: 'session/set_mode'
		params: (Dictionary new
			at: 'sessionId' put: aSession sessionId;
			at: 'modeId' put: aModeId;
			yourself)
		do: aBlock
		onError: anErrorBlock
]

{ #category : 'accessing' }
GtAcpClient >> transport [
	^ transport
]
