Class {
	#name : 'GtAcpMessageElement',
	#superclass : 'BlElement',
	#instVars : [
		'message',
		'contentsElement',
		'roleElement',
		'subscriber'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'initialization' }
GtAcpMessageElement >> initialize [
	super initialize.
	subscriber := Object new.
	self layout: BlLinearLayout vertical.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical fitContent ].
	self padding: (BlInsets all: 8).
	self margin: (BlInsets top: 2 bottom: 2).
	self initializeRoleElement.
	self initializeContentsElement.
	self addChild: roleElement as: #role.
	self addChild: contentsElement as: #contents
]

{ #category : 'initialization' }
GtAcpMessageElement >> initializeContentsElement [
	contentsElement := BrEditor new
		hMatchParent;
		vFitContentLimited;
		aptitude: BrGlamorousRegularEditorAptitude;
		beReadOnlyWithSelection
]

{ #category : 'initialization' }
GtAcpMessageElement >> initializeRoleElement [
	roleElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new bold; fontSize: 12);
		text: '';
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 4)
]

{ #category : 'accessing' }
GtAcpMessageElement >> message [
	^ message
]

{ #category : 'accessing' }
GtAcpMessageElement >> message: aGtAcpMessage [
	message ifNotNil: [ 
		message announcer unsubscribe: subscriber ].
	message := aGtAcpMessage.
	self updateRole.
	self updateContents.
	message announcer 
		when: GtAcpMessageUpdated 
		send: #onMessageUpdated: 
		to: self
]

{ #category : 'updating' }
GtAcpMessageElement >> onMessageUpdated: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ self updateContents ])
]

{ #category : 'updating' }
GtAcpMessageElement >> updateContents [
	contentsElement text: message fullText asRopedText
]

{ #category : 'updating' }
GtAcpMessageElement >> updateRole [
	| roleName color |
	roleName := message role.
	color := roleName = 'user'
		ifTrue: [ BrGlamorousColors primaryBorderColor ]
		ifFalse: [ BrGlamorousColors successBackgroundColor ].
	roleElement text: (roleName asRopedText foreground: color)
]
