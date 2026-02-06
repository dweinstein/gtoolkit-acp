Class {
	#name : 'GtAcpClientRegistry',
	#superclass : 'Object',
	#instVars : [
		'clients',
		'announcer'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'accessing' }
GtAcpClientRegistry class >> reset [
	uniqueInstance := nil
]

{ #category : 'accessing' }
GtAcpClientRegistry class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
GtAcpClientRegistry >> activeClients [
	^ clients select: [ :c | c isConnected ]
]

{ #category : 'accessing' }
GtAcpClientRegistry >> announcer [
	^ announcer
]

{ #category : 'registration' }
GtAcpClientRegistry >> cleanup [
	"Remove all disconnected clients"
	| dead |
	dead := clients reject: [ :c | c isConnected ].
	dead do: [ :c | self unregister: c ]
]

{ #category : 'accessing' }
GtAcpClientRegistry >> clients [
	^ clients
]

{ #category : 'private' }
GtAcpClientRegistry >> cwdMenuItemsForLaunchFrom: anElement [
	"Build menu items for CWD selection dropdown — recent CWDs + Browse"
	| items |
	items := OrderedCollection new.
	self recentCwds do: [ :aCwd |
		items add: (aCwd -> [ :e |
			GtClaudeCodeClient launchIn: aCwd.
			e fireEvent: BrDropdownHideWish new.
			e phlow spawnObject: GtAcpClientRegistry uniqueInstance ]) ].
	items add: ('Browse...' -> [ :e |
		e fireEvent: BrDropdownHideWish new.
		e phlow spawnObject: GtClaudeCodeClient defaultCwd asFileReference ]).
	^ items
]

{ #category : 'private' }
GtAcpClientRegistry >> cwdMenuItemsForNewSessionOn: aClient [
	"Build menu items for CWD selection dropdown — creates a new session on an existing client"
	| items |
	items := OrderedCollection new.
	self recentCwds do: [ :aCwd |
		items add: (aCwd -> [ :e |
			aClient newSessionIn: aCwd do: [ :session |
				e enqueueTask: (BlTaskAction new action: [
					e phlow spawnObject: session ]) ]
			onError: [ :err |
				e enqueueTask: (BlTaskAction new action: [
					e phlow spawnObject: ('Session error: ', err printString) ]) ].
			e fireEvent: BrDropdownHideWish new ]) ].
	items add: ('Browse...' -> [ :e |
		e fireEvent: BrDropdownHideWish new.
		e phlow spawnObject: GtClaudeCodeClient defaultCwd asFileReference ]).
	^ items
]

{ #category : 'gt - extensions' }
GtAcpClientRegistry >> gtCleanupActionFor: anAction [
	<gtAction>
	^ anAction button
		tooltip: 'Remove disconnected clients';
		icon: BrGlamorousVectorIcons bin;
		action: [ :aButton | self cleanup ]
]

{ #category : 'views' }
GtAcpClientRegistry >> gtClientsTreeFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Clients';
		priority: 1;
		items: [ self clients sorted: [ :a :b | a createdAt > b createdAt ] ];
		children: [ :item |
			(item isKindOf: GtAcpClient)
				ifTrue: [ item sessions values ]
				ifFalse: [ #() ] ];
		expandAll;
		column: 'Status' 
			icon: [ :item |
				(item isKindOf: GtAcpClient)
					ifTrue: [ item isConnected
						ifTrue: [ BlElement new size: 8@8; geometry: BlCircleGeometry new; background: Color green ]
						ifFalse: [ BlElement new size: 8@8; geometry: BlCircleGeometry new; background: Color lightGray ] ]
					ifFalse: [ BlElement new size: 0@0 ] ]
			width: 30;
		column: 'Name'
			text: [ :item |
				(item isKindOf: GtAcpClient)
					ifTrue: [ item printString ]
					ifFalse: [ (item isKindOf: GtAcpSession)
						ifTrue: [ 
							| desc |
							desc := item cwd ifNil: [ 'session' ].
							item currentModelId ifNotNil: [ :m | desc := desc, ' [', m, ']' ].
							desc ]
						ifFalse: [ item printString ] ] ]
			weight: 1;
		column: 'Messages'
			text: [ :item |
				(item isKindOf: GtAcpSession)
					ifTrue: [ item messages size asString ]
					ifFalse: [ '' ] ]
			width: 70;
		column: 'Created'
			text: [ :item |
				(item isKindOf: GtAcpClient)
					ifTrue: [ String streamContents: [ :s | item createdAt printHMSOn: s ] ]
					ifFalse: [ '' ] ]
			width: 80;
		column: ''
			stencil: [ :item |
				((item isKindOf: GtAcpClient) and: [ item isConnected ])
					ifTrue: [
						BrButton new beTinySize
							aptitude: BrGlamorousButtonWithIconAptitude
								+ (BrGlamorousWithExplicitDropdownAptitude
									handle: [ BrButton new
										aptitude: BrGlamorousButtonRectangularAptitude + BrGlamorousButtonIconAptitude;
										icon: BrGlamorousVectorIcons add ]
									content: [
										BrGlamorousSimpleContextMenuContent new
											items: (self cwdMenuItemsForNewSessionOn: item);
											yourself ]);
							icon: BrGlamorousVectorIcons add;
							label: 'New session on this client' ]
					ifFalse: [ BlElement new size: 0@0 ] ]
			width: 40;
		send: [ :item | item ];
		updateWhen: GtAcpClientRegistryUpdated in: [ self announcer ];
		actionUpdateButton
]

{ #category : 'gt - extensions' }
GtAcpClientRegistry >> gtQuickLaunchActionFor: anAction [
	<gtAction>
	^ anAction dropdown
		tooltip: 'Launch new Claude Code';
		icon: BrGlamorousVectorIcons play;
		content: [ :aButton |
			BrGlamorousSimpleContextMenuContent new
				items: (self cwdMenuItemsForLaunchFrom: aButton);
				yourself ]
]

{ #category : 'private' }
GtAcpClientRegistry >> handleClientUpdated [
	"Re-announce so registry views refresh when any client's status changes"
	announcer announce: GtAcpClientRegistryUpdated new
]

{ #category : 'initialization' }
GtAcpClientRegistry >> initialize [
	super initialize.
	clients := OrderedCollection new.
	announcer := Announcer new
]

{ #category : 'printing' }
GtAcpClientRegistry >> printOn: aStream [
	aStream
		nextPutAll: 'GtAcpClientRegistry(';
		print: clients size;
		nextPutAll: ' clients, ';
		print: self activeClients size;
		nextPutAll: ' active)'
]

{ #category : 'accessing' }
GtAcpClientRegistry >> recentCwds [
	"Derive recent CWDs dynamically from all sessions across all clients"
	| cwds |
	cwds := OrderedCollection new.
	clients do: [ :c |
		c sessions values do: [ :s |
			(s cwd notNil and: [ (cwds includes: s cwd) not ])
				ifTrue: [ cwds add: s cwd ] ] ].
	^ cwds
]

{ #category : 'registration' }
GtAcpClientRegistry >> register: aClient [
	"Add a client to the registry if not already present. Subscribe to its announcer for lifecycle events."
	(clients includes: aClient) ifTrue: [ ^ self ].
	clients add: aClient.
	aClient announcer
		when: GtAcpClientUpdated
		send: #handleClientUpdated
		to: self.
	announcer announce: GtAcpClientRegistryUpdated new
]

{ #category : 'accessing' }
GtAcpClientRegistry >> unregister: aClient [
	"Remove a client from the registry, disconnecting it if needed"
	clients remove: aClient ifAbsent: [ ^ self ].
	aClient announcer unsubscribe: self.
	aClient isConnected ifTrue: [ aClient disconnect ].
	announcer announce: GtAcpClientRegistryUpdated new
]
