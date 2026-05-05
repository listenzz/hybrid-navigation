import React from 'react';
import { View, ScrollView } from 'react-native';
import { NavigationProps } from 'hybrid-navigation';

import styles from './Styles';
import TopBar from './TopBar';
import { DemoNote, DemoSection } from './DemoUI';

export default function PassOptions({ navigator }: NavigationProps) {
	return (
		<View style={styles.screen}>
			<TopBar title="Pass Options" navigator={navigator} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<DemoSection title="Options">
						<DemoNote
							title="Shared RN TopBar"
							body="This scene receives navigation options and renders with the shared React Native top bar."
						/>
					</DemoSection>
				</View>
			</ScrollView>
		</View>
	);
}
