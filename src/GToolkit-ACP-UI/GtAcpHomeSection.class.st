Class {
	#name : 'GtAcpHomeSection',
	#superclass : 'GtHomeMultiCardSection',
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'cards' }
GtAcpHomeSection >> acpShellCard [
	<gtSectionCard>
	| card |
	card := GtHomeCard explicit.
	^ card
		title: 'ACP Shell';
		description: 'New Claude Code session';
		priority: 10;
		stencil: [
			| container titleLabel subtitleLabel |
			titleLabel := BrLabel new
				beLargeSize;
				padding: (BlInsets bottom: 5);
				aptitude: BrGlamorousLabelAptitude new bold;
				text: 'ACP Shell'.
			subtitleLabel := BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: Color gray; fontSize: 12);
				text: 'New Claude Code session'.
			container := BrVerticalPane new
				exact: 250 @ 150;
				background: Color white;
				aptitude: BrShadowAptitude new beLarge
					+ (BrGlamorousButtonExteriorAptitude new
						backgroundPaint: Color white;
						borderPaint: Color transparent);
				padding: (BlInsets all: 15);
				margin: (BlInsets
					top: self spaceGap
					left: 2 * self spaceGap
					bottom: 2 * self spaceGap
					right: 2 * self spaceGap);
				when: BlClickEvent do: [ :anEvent |
					anEvent consumed: true.
					self launchShellFrom: container ].
			container addChild: titleLabel preventMeAndChildrenMouseEvents.
			container addChild: subtitleLabel preventMeAndChildrenMouseEvents.
			container ]
]

{ #category : 'actions' }
GtAcpHomeSection >> launchShellFrom: anElement [
	| client |
	client := GtAcpClient new.
	client connectTo: '/Users/user/.nvm/versions/node/v20.12.2/bin/node' args: #('/Users/user/personal/acp/claude-code-acp/dist/index.js').
	client initializeDo: [ :result |
		client newSessionIn: '/Users/user/personal/gt' do: [ :session |
			anElement enqueueTask: (BlTaskAction new action: [
				anElement phlow spawnOrShowObject: session ]) ]
		onError: [ :err |
			anElement enqueueTask: (BlTaskAction new action: [
				anElement phlow spawnOrShowObject: ('Session error: ' , err printString) ]) ] ]
	onError: [ :err |
		anElement enqueueTask: (BlTaskAction new action: [
			anElement phlow spawnOrShowObject: ('Init error: ' , err printString) ]) ]
]

{ #category : 'accessing' }
GtAcpHomeSection >> sectionTitle [
	^ 'ACP Shell'
]
