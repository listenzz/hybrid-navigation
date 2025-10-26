import React, { ComponentType } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function SafeAreaContextHOC(WrappedComponent: ComponentType<any>) {
	return class SafeAreaContextProvider extends React.Component {
		static navigationItem = (WrappedComponent as any).navigationItem;
		render() {
			return (
				<SafeAreaProvider>
					<WrappedComponent {...this.props} />
				</SafeAreaProvider>
			);
		}
	};
}
