Class {
	#name : 'GtAcpClient',
	#superclass : 'Object',
	#instVars : [
		'transport',
		'sessions',
		'announcer',
		'agentInfo'
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

{ #category : 'lifecycle' }
GtAcpClient >> connectTo: programPath args: anArray [
	transport := GtAcpTransport on: programPath args: anArray.
	self registerHandlers.
	transport start
]

{ #category : 'lifecycle' }
GtAcpClient >> disconnect [
	transport ifNotNil: [ transport terminate ]
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

{ #category : 'private' }
GtAcpClient >> handlePermissionRequest: params requestId: anId [
	| sessionId session request |
	sessionId := params at: 'sessionId'.
	session := sessions at: sessionId ifAbsent: [ ^ self ].
	request := params copy.
	request at: 'requestId' put: anId.
	session pendingPermissions add: request.
	session announcer announce: GtAcpPermissionRequested new
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
	announcer := Announcer new
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

{ #category : 'session management' }
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

{ #category : 'session management' }
GtAcpClient >> prompt: aString inSession: aSession do: aBlock onError: anErrorBlock [
	aSession messages add: (GtAcpMessage user: aString).
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
