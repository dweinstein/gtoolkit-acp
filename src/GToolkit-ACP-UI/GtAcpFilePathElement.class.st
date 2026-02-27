Class {
	#name : 'GtAcpFilePathElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'pathButton',
		'fileError',
		'currentPath',
		'onPathChanged',
		'pathLabel'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'initialization' }
GtAcpFilePathElement >> initialize [
	super initialize.
	currentPath := '' asFileReference.
	onPathChanged := [ :aPath | ].
	self vFitContent.
	self hMatchParent.
	self alignCenterLeft.
	self cellSpacing: 4.
	self addChild: self makePathLabel.
	self addChild: self makePathDropdown.
	self addChild: self makeFileError
]

{ #category : 'accessing' }
GtAcpFilePathElement >> label: aString [
	pathLabel text: aString
]

{ #category : 'building' }
GtAcpFilePathElement >> makeDropdownContent [
	| aFileBrowser |
	aFileBrowser := BrFileSelector new.
	aFileBrowser
		vExact: 250;
		hExact: 400;
		buttonLabel: 'Set';
		padding: (BlInsets all: 10);
		file: currentPath;
		addAptitude: BrGlamorousWithVerticalResizerAptitude
			+ BrGlamorousWithHorizontalResizerAptitude
			+ BrGlamorousWithHorizontalResizerAptitude new beLeft.
	aFileBrowser
		okAction: [ :aFileReference |
			self path: aFileReference.
			aFileBrowser fireEvent: BrDropdownHideWish new ].
	aFileBrowser
		fileFilterBlock: [ :aFileReference |
			(FileSystemDirectoryEntry reference: aFileReference) isHidden not ].
	^ aFileBrowser
]

{ #category : 'building' }
GtAcpFilePathElement >> makeFileError [
	^ fileError := BrLabel new hFitContent
		margin: (BlInsets left: 5);
		aptitude: (BrGlamorousLabelAptitude new
			foreground: BrGlamorousColors errorBackgroundColor);
		text: ''
]

{ #category : 'building' }
GtAcpFilePathElement >> makePathDropdown [
	^ pathButton := BrButton new
		hFitContentLimited;
		vFitContent;
		margin: (BlInsets left: 0 right: 0);
		aptitude: BrGlamorousButtonWithLabelAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [ BrButton new
					fitContent;
					aptitude: BrGlamorousButtonWithLabelAptitude - BrGlamorousButtonExteriorAptitude;
					label: self pathDisplayString ]
				content: [ self makeDropdownContent ])
]

{ #category : 'building' }
GtAcpFilePathElement >> makePathLabel [
	^ pathLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: Color gray; fontSize: 12);
		text: 'Path:'
]

{ #category : 'accessing' }
GtAcpFilePathElement >> onPathChanged: aBlock [
	onPathChanged := aBlock
]

{ #category : 'accessing' }
GtAcpFilePathElement >> path: aFileReference [
	currentPath := aFileReference asFileReference.
	pathButton label: self pathDisplayString.
	currentPath exists
		ifTrue: [ fileError text: '' ]
		ifFalse: [ fileError text: 'File does not exist' ].
	onPathChanged value: currentPath pathString
]

{ #category : 'accessing' }
GtAcpFilePathElement >> pathDisplayString [
	| pathString |
	pathString := currentPath pathString.
	^ pathString size > 45
		ifTrue: [ (pathString first: 20) , '...' , (pathString last: 22) ]
		ifFalse: [ pathString ]
]
