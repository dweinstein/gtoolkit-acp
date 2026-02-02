Class {
	#name : 'GtAcpToolCallElement',
	#superclass : 'BlElement',
	#instVars : [
		'toolCall',
		'headerElement',
		'statusIcon',
		'titleLabel',
		'errorLabel',
		'expandArrow',
		'detailContainer',
		'isExpanded'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'private' }
GtAcpToolCallElement >> buildDetailContent [
	"Build expanded detail view showing input params and output, similar to Claude Code CLI format"
	detailContainer removeChildren.
	
	"Input parameters"
	(toolCall rawInput notNil and: [ toolCall rawInput notEmpty ]) ifTrue: [
		toolCall rawInput keysAndValuesDo: [ :key :value |
			| valueText |
			valueText := value asString.
			valueText size > 300 ifTrue: [ valueText := (valueText first: 300), '...' ].
			detailContainer addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color darkGray);
				hMatchParent; vFitContent;
				text: (key asString, ': ', valueText)) ] ].
	
	"Output / response"
	toolCall rawOutput ifNotNil: [ :output |
		| outputText |
		outputText := output asString.
		outputText size > 500 ifTrue: [ outputText := (outputText first: 500), '...' ].
		detailContainer addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 10; foreground: Color gray);
			text: '---').
		detailContainer addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 11; 
				foreground: (toolCall status = 'failed' 
					ifTrue: [ Color red darker ] 
					ifFalse: [ Color darkGray ]));
			hMatchParent; vFitContent;
			text: outputText) ].
	
	"Click to inspect in detail"
	detailContainer addChild: (BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 10; foreground: (Color blue alpha: 0.7));
		text: 'click to inspect';
		margin: (BlInsets top: 2);
		when: BlClickEvent do: [ :e |
			e consumed: true.
			self phlow spawnOrShowObject: toolCall ])
]

{ #category : 'initialization' }
GtAcpToolCallElement >> initialize [
	super initialize.
	isExpanded := false.
	self layout: BlLinearLayout vertical.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical fitContent ].
	self padding: (BlInsets top: 2 bottom: 2 left: 8 right: 8).
	self margin: (BlInsets top: 2 bottom: 2).
	self background: (Color veryLightGray alpha: 0.2).
	self border: (BlBorder paint: (Color gray alpha: 0.3) width: 1).
	
	"Header row: status icon + title + expand arrow"
	headerElement := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft.
	headerElement when: BlClickEvent do: [ :e |
		e consumed: true.
		self toggleExpanded ].
	statusIcon := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 12);
		text: '...';
		margin: (BlInsets right: 6).
	titleLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color darkGray);
		hMatchParent;
		vFitContent.
	expandArrow := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 10; foreground: Color gray);
		text: '>';
		margin: (BlInsets left: 6).
	headerElement addChild: statusIcon.
	headerElement addChild: titleLabel.
	headerElement addChild: expandArrow.
	
	"Detail container (hidden by default)"
	detailContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 4 left: 18);
		visibility: BlVisibility gone.
	
	"Error label (hidden by default)"
	errorLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: (Color red darker));
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 2 left: 18);
		visibility: BlVisibility gone.
	
	self addChild: headerElement.
	self addChild: errorLabel.
	self addChild: detailContainer
]

{ #category : 'actions' }
GtAcpToolCallElement >> toggleExpanded [
	isExpanded := isExpanded not.
	isExpanded
		ifTrue: [
			expandArrow text: 'v'.
			self buildDetailContent.
			detailContainer visibility: BlVisibility visible ]
		ifFalse: [
			expandArrow text: '>'.
			detailContainer removeChildren.
			detailContainer visibility: BlVisibility gone ]
]

{ #category : 'accessing' }
GtAcpToolCallElement >> toolCall [
	^ toolCall
]

{ #category : 'accessing' }
GtAcpToolCallElement >> toolCall: aGtAcpToolCall [
	toolCall := aGtAcpToolCall.
	self update
]

{ #category : 'updating' }
GtAcpToolCallElement >> update [
	| titleText icon |
	titleText := toolCall title ifNil: [ 'Tool call' ].
	toolCall inputSummary ifNotNil: [ :s | titleText := titleText, ' - ', s ].
	titleLabel text: titleText.
	
	toolCall status = 'completed' ifTrue: [
		icon := '+'.
		statusIcon aptitude foreground: Color gray.
		self background: (Color veryLightGray alpha: 0.2).
		self border: (BlBorder paint: (Color gray alpha: 0.3) width: 1).
		errorLabel visibility: BlVisibility gone ].
	toolCall status = 'failed' ifTrue: [
		| errorText |
		icon := 'x'.
		statusIcon aptitude foreground: Color red.
		self background: (Color red alpha: 0.05).
		self border: (BlBorder paint: (Color red alpha: 0.3) width: 1).
		errorText := toolCall rawOutput ifNil: [ '' ].
		errorText isEmpty ifFalse: [
			errorLabel text: (errorText asString truncateTo: 200).
			errorLabel visibility: BlVisibility visible ] ].
	(toolCall status = 'pending' or: [ toolCall status = 'in_progress' or: [ toolCall status isNil ] ]) ifTrue: [
		icon := '...'.
		statusIcon aptitude foreground: Color gray.
		self background: (Color veryLightGray alpha: 0.2).
		self border: (BlBorder paint: (Color gray alpha: 0.3) width: 1).
		errorLabel visibility: BlVisibility gone ].
	
	statusIcon text: icon.
	
	"Refresh detail content if expanded"
	isExpanded ifTrue: [ self buildDetailContent ]
]
