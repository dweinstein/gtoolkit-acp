Class {
	#name : 'GtAcpThinkingElement',
	#superclass : 'BlElement',
	#instVars : [
		'message',
		'isExpanded',
		'headerElement',
		'expandArrow',
		'titleLabel',
		'contentEditor'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'building' }
GtAcpThinkingElement >> buildContent [
	message ifNil: [ ^ self ].
	contentEditor text: message thinking asRopedText
]

{ #category : 'initialization' }
GtAcpThinkingElement >> initialize [
	super initialize.
	isExpanded := false.
	self layout: BlLinearLayout vertical.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical fitContent ].
	self padding: (BlInsets all: 4).
	self margin: (BlInsets bottom: 4).
	self background: (Color veryLightGray alpha: 0.15).
	
	"Header row: thinking icon + title + expand arrow"
	headerElement := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft.
	headerElement when: BlClickEvent do: [ :e |
		e consumed: true.
		self toggleExpanded ].
	
	titleLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color gray);
		hMatchParent;
		vFitContent.
	
	expandArrow := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 10; foreground: Color gray);
		text: '>';
		margin: (BlInsets left: 6).
	
	headerElement addChild: titleLabel.
	headerElement addChild: expandArrow.
	
	"Content editor (hidden by default, lazily populated)"
	contentEditor := BrEditor new
		hMatchParent;
		vFitContentLimited;
		aptitude: (BrGlamorousRegularEditorAptitude new fontSize: 11; foreground: (Color gray alpha: 0.8));
		beReadOnlyWithSelection;
		padding: (BlInsets top: 4 left: 4);
		visibility: BlVisibility gone.
	
	self addChild: headerElement.
	self addChild: contentEditor
]

{ #category : 'accessing' }
GtAcpThinkingElement >> message [
	^ message
]

{ #category : 'accessing' }
GtAcpThinkingElement >> message: aGtAcpMessage [
	message := aGtAcpMessage.
	self update
]

{ #category : 'actions' }
GtAcpThinkingElement >> toggleExpanded [
	isExpanded := isExpanded not.
	isExpanded
		ifTrue: [
			expandArrow text: 'v'.
			self buildContent.
			contentEditor visibility: BlVisibility visible ]
		ifFalse: [
			expandArrow text: '>'.
			contentEditor visibility: BlVisibility gone ]
]

{ #category : 'updating' }
GtAcpThinkingElement >> update [
	| thinkingText charCount |
	message ifNil: [ ^ self ].
	thinkingText := message thinking.
	charCount := thinkingText size.
	titleLabel text: ('Thinking (' , charCount printString , ' chars)').
	isExpanded ifTrue: [ self buildContent ]
]
