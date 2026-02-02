Class {
	#name : 'GtAcpSession',
	#superclass : 'Object',
	#instVars : [
		'sessionId',
		'cwd',
		'currentModeId',
		'availableModes',
		'availableModels',
		'currentModelId',
		'messages',
		'plan',
		'pendingPermissions',
		'availableCommands',
		'announcer',
		'client',
		'permissionHistory',
		'alwaysAllowedTools'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpSession class >> fromResponse: aDictionary [
	| session modelsDict modesDict |
	session := self new.
	session sessionId: (aDictionary at: 'sessionId').
	
	modelsDict := aDictionary at: 'models' ifAbsent: [ Dictionary new ].
	session currentModelId: (modelsDict at: 'currentModelId' ifAbsent: [ nil ]).
	session availableModels: (modelsDict at: 'availableModels' ifAbsent: [ #() ]).
	
	modesDict := aDictionary at: 'modes' ifAbsent: [ Dictionary new ].
	session currentModeId: (modesDict at: 'currentModeId' ifAbsent: [ 'default' ]).
	session availableModes: (modesDict at: 'availableModes' ifAbsent: [ #() ]).
	
	^ session
]

{ #category : 'private' }
GtAcpSession >> addPermissionRequest: aDictionary [
	pendingPermissions add: aDictionary.
	announcer announce: GtAcpPermissionRequested new
]

{ #category : 'accessing' }
GtAcpSession >> alwaysAllowedTools [
	^ alwaysAllowedTools ifNil: [ alwaysAllowedTools := Set new ]
]

{ #category : 'accessing' }
GtAcpSession >> announcer [
	^ announcer
]

{ #category : 'accessing' }
GtAcpSession >> availableCommands [
	^ availableCommands
]

{ #category : 'accessing' }
GtAcpSession >> availableCommands: aCollection [
	availableCommands := aCollection
]

{ #category : 'accessing' }
GtAcpSession >> availableModels [
	^ availableModels
]

{ #category : 'accessing' }
GtAcpSession >> availableModels: aCollection [
	availableModels := aCollection
]

{ #category : 'accessing' }
GtAcpSession >> availableModes [
	^ availableModes
]

{ #category : 'accessing' }
GtAcpSession >> availableModes: aCollection [
	availableModes := aCollection
]

{ #category : 'accessing' }
GtAcpSession >> client [
	^ client
]

{ #category : 'accessing' }
GtAcpSession >> client: aGtAcpClient [
	client := aGtAcpClient
]

{ #category : 'private' }
GtAcpSession >> currentAssistantMessage [
	| lastMessage |
	messages ifNotEmpty: [ 
		lastMessage := messages last.
		(lastMessage isAssistant and: [ lastMessage isComplete not ])
			ifTrue: [ ^ lastMessage ] ].
	
	lastMessage := GtAcpMessage assistant.
	messages add: lastMessage.
	announcer announce: GtAcpSessionUpdated new.
	^ lastMessage
]

{ #category : 'accessing' }
GtAcpSession >> currentModeId [
	^ currentModeId
]

{ #category : 'accessing' }
GtAcpSession >> currentModeId: aString [
	currentModeId := aString
]

{ #category : 'accessing' }
GtAcpSession >> currentModelId [
	^ currentModelId
]

{ #category : 'accessing' }
GtAcpSession >> currentModelId: aString [
	currentModelId := aString
]

{ #category : 'private' }
GtAcpSession >> currentUserMessage [
	| lastMessage |
	messages ifNotEmpty: [ 
		lastMessage := messages last.
		(lastMessage isUser and: [ lastMessage isComplete not ])
			ifTrue: [ ^ lastMessage ] ].
	
	lastMessage := GtAcpMessage user.
	messages add: lastMessage.
	announcer announce: GtAcpSessionUpdated new.
	^ lastMessage
]

{ #category : 'accessing' }
GtAcpSession >> cwd [
	^ cwd
]

{ #category : 'accessing' }
GtAcpSession >> cwd: aString [
	cwd := aString
]

{ #category : 'actions' }
GtAcpSession >> gtCancelActionFor: anAction [
	<gtAction>
	(client isNil or: [ client isConnected not ]) ifTrue: [ ^ anAction noAction ].
	^ anAction button
		tooltip: 'Cancel current operation';
		icon: BrGlamorousVectorIcons cancel;
		action: [ :aButton | client cancelSession: self ]
]

{ #category : 'gt views' }
GtAcpSession >> gtMessagesFor: aView [
	<gtView>
	^ aView list
		title: 'Messages';
		priority: 10;
		items: [ messages ];
		itemText: [ :msg | msg role asString, ': ', msg preview ]
]

{ #category : 'gt-views' }
GtAcpSession >> gtPermissionDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Permission Details';
		priority: 16;
		items: [ (permissionHistory ifNil: [ #() ]) reversed ];
		column: 'Status' text: [ :req | 
			| status |
			status := req at: 'status' ifAbsent: [ '?' ].
			status = 'auto-allowed'
				ifTrue: [ status asRopedText foreground: Color gray ]
				ifFalse: [ status = 'allowed'
					ifTrue: [ status asRopedText foreground: Color darkGreen ]
					ifFalse: [ status asRopedText foreground: Color red ] ] ] width: 110;
		column: 'Tool' text: [ :req | 
			| title |
			title := (req at: 'toolCall' ifAbsent: [ Dictionary new ]) 
				at: 'title' ifAbsent: [ '?' ].
			"Strip common mcp prefix for readability"
			(title beginsWith: 'mcp__gtmcp__')
				ifTrue: [ title allButFirst: 12 ]
				ifFalse: [ title ] ] width: 180;
		column: 'Input' text: [ :req |
			| rawInput |
			rawInput := (req at: 'toolCall' ifAbsent: [ Dictionary new ])
				at: 'rawInput' ifAbsent: [ Dictionary new ].
			', ' join: (rawInput associations collect: [ :assoc |
				assoc key asString, ': ', assoc value printString ]) ] width: 350;
		column: 'Decision' text: [ :req |
			', ' join: ((req at: 'options' ifAbsent: [ #() ]) collect: [ :o | o at: 'name' ifAbsent: [ '?' ] ]) ] width: 200
]

{ #category : 'gt - views' }
GtAcpSession >> gtPermissionsFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Permissions';
		priority: 15;
		items: [ (permissionHistory ifNil: [ #() ]) reversed ];
		expandAll;
		children: [ :item |
			(item isKindOf: Association)
				ifTrue: [ 
					(item value isDictionary)
						ifTrue: [ item value associations ]
						ifFalse: [ 
							(item value isArray or: [ item value isKindOf: OrderedCollection ])
								ifTrue: [ item value collectWithIndex: [ :v :i | i -> v ] ]
								ifFalse: [ #() ] ] ]
				ifFalse: [
					(item isDictionary)
						ifTrue: [ 
							| interesting |
							interesting := item associations select: [ :a | 
								(#('requestId' 'sessionId' 'status' 'timestamp') includes: a key) not ].
							interesting ]
						ifFalse: [ #() ] ] ];
		column: 'Key' text: [ :item |
			(item isKindOf: Association)
				ifTrue: [ item key ]
				ifFalse: [
					(item isDictionary)
						ifTrue: [ (item at: 'toolCall' ifAbsent: [ Dictionary new ]) at: 'title' ifAbsent: [ '?' ] ]
						ifFalse: [ item ] ] ] width: 250;
		column: 'Value' text: [ :item |
			(item isKindOf: Association)
				ifTrue: [ 
					(item value isDictionary or: [ item value isArray or: [ item value isKindOf: OrderedCollection ] ])
						ifTrue: [ '' ]
						ifFalse: [ item value printString ] ]
				ifFalse: [
					(item isDictionary)
						ifTrue: [ item at: 'status' ifAbsent: [ '' ] ]
						ifFalse: [ '' ] ] ] width: 200;
		column: 'Time' text: [ :item |
			(item isKindOf: Association)
				ifTrue: [ '' ]
				ifFalse: [
					(item isDictionary)
						ifTrue: [ (item at: 'timestamp' ifAbsent: [ '' ]) printString ]
						ifFalse: [ '' ] ] ] width: 180
]

{ #category : 'gt views' }
GtAcpSession >> gtPlanFor: aView [
	<gtView>
	^ aView list
		title: 'Plan';
		priority: 20;
		items: [ plan ]
]

{ #category : 'gt - views' }
GtAcpSession >> gtShellFor: aView [
	<gtView>
	^ aView explicit
		title: 'Shell';
		priority: 5;
		stencil: [ 
			GtAcpShellElement on: client session: self ]
]

{ #category : 'initialization' }
GtAcpSession >> initialize [
	super initialize.
	messages := OrderedCollection new.
	plan := OrderedCollection new.
	pendingPermissions := OrderedCollection new.
	permissionHistory := OrderedCollection new.
	availableCommands := OrderedCollection new.
	availableModes := #().
	availableModels := #().
	announcer := Announcer new
]

{ #category : 'private' }
GtAcpSession >> markCurrentMessageComplete [
	messages ifNotEmpty: [ 
		messages last isComplete ifFalse: [ 
			messages last markComplete ] ]
]

{ #category : 'accessing' }
GtAcpSession >> messages [
	^ messages
]

{ #category : 'accessing' }
GtAcpSession >> pendingPermissions [
	^ pendingPermissions
]

{ #category : 'accessing' }
GtAcpSession >> permissionHistory [
	^ permissionHistory ifNil: [ permissionHistory := OrderedCollection new ]
]

{ #category : 'accessing' }
GtAcpSession >> plan [
	^ plan
]

{ #category : 'printing' }
GtAcpSession >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: (sessionId ifNil: [ 'no id' ]).
	aStream nextPutAll: ' - '.
	aStream print: messages size.
	aStream nextPutAll: ' messages'.
	aStream nextPut: $)
]

{ #category : 'updating' }
GtAcpSession >> processAgentMessageChunk: aDictionary [
	| message contentBlock |
	message := self currentAssistantMessage.
	contentBlock := aDictionary at: 'content'.
	
	(contentBlock at: 'type') = 'text'
		ifTrue: [ 
			message appendText: (contentBlock at: 'text') ]
		ifFalse: [ 
			message addContentBlock: contentBlock ].
	
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'updating' }
GtAcpSession >> processAvailableCommands: aDictionary [
	availableCommands := aDictionary at: 'availableCommands' ifAbsent: [ #() ].
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'updating' }
GtAcpSession >> processCurrentModeUpdate: aDictionary [
	currentModeId := aDictionary at: 'currentModeId'.
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'updating' }
GtAcpSession >> processPlan: aDictionary [
	| entries |
	entries := aDictionary at: 'entries'.
	plan := entries collect: [ :e | GtAcpPlanEntry fromDictionary: e ].
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'processing' }
GtAcpSession >> processToolCall: aDictionary [
	| message toolCall toolCallId existing |
	message := self currentAssistantMessage.
	toolCallId := aDictionary at: 'toolCallId' ifAbsent: [ nil ].
	"Check if this is an update to an existing tool call"
	(toolCallId notNil and: [ 
		existing := message toolCalls 
			detect: [ :tc | tc toolCallId = toolCallId ] 
			ifNone: [ nil ].
		existing notNil ])
		ifTrue: [ existing applyUpdate: aDictionary ]
		ifFalse: [ 
			toolCall := GtAcpToolCall fromDictionary: aDictionary.
			message addToolCall: toolCall ].
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'updating' }
GtAcpSession >> processToolCallUpdate: aDictionary [
	| message toolCall toolCallId |
	message := self currentAssistantMessage.
	toolCallId := aDictionary at: 'toolCallId'.
	toolCall := message toolCalls detect: [ :tc | tc toolCallId = toolCallId ] ifNone: [ ^ self ].
	toolCall applyUpdate: aDictionary.
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'updating' }
GtAcpSession >> processUpdate: aDictionary [
	| updateType |
	updateType := aDictionary at: 'sessionUpdate'.
	
	updateType = 'agent_message_chunk' ifTrue: [ ^ self processAgentMessageChunk: aDictionary ].
	updateType = 'user_message_chunk' ifTrue: [ ^ self processUserMessageChunk: aDictionary ].
	updateType = 'agent_thought_chunk' ifTrue: [ ^ self ]. "ignore for now"
	updateType = 'tool_call' ifTrue: [ ^ self processToolCall: aDictionary ].
	updateType = 'tool_call_update' ifTrue: [ ^ self processToolCallUpdate: aDictionary ].
	updateType = 'plan' ifTrue: [ ^ self processPlan: aDictionary ].
	updateType = 'available_commands_update' ifTrue: [ ^ self processAvailableCommands: aDictionary ].
	updateType = 'current_mode_update' ifTrue: [ ^ self processCurrentModeUpdate: aDictionary ].
	updateType = 'session_info_update' ifTrue: [ ^ self ]. "ignore for now"
	updateType = 'config_option_update' ifTrue: [ ^ self ]. "ignore for now"
]

{ #category : 'updating' }
GtAcpSession >> processUserMessageChunk: aDictionary [
	| message contentBlock |
	message := self currentUserMessage.
	contentBlock := aDictionary at: 'content'.
	
	(contentBlock at: 'type') = 'text'
		ifTrue: [ 
			message appendText: (contentBlock at: 'text') ]
		ifFalse: [ 
			message addContentBlock: contentBlock ].
	
	announcer announce: GtAcpSessionUpdated new
]

{ #category : 'accessing' }
GtAcpSession >> sessionId [
	^ sessionId
]

{ #category : 'accessing' }
GtAcpSession >> sessionId: aString [
	sessionId := aString
]
