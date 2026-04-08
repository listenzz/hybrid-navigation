import React, { ComponentType } from 'react';
import { SafeAreaProvider, initialWindowMetrics } from 'react-native-safe-area-context';

const zeroInsets = { top: 0, bottom: 0, left: 0, right: 0 };
const initialMetrics =
	initialWindowMetrics ? { ...initialWindowMetrics, insets: zeroInsets } : undefined;

export default function SafeAreaContextHOC(WrappedComponent: ComponentType<any>) {
	return class SafeAreaContextProvider extends React.Component {
		static navigationItem = (WrappedComponent as any).navigationItem;
		render() {
			return (
				<SafeAreaProvider initialMetrics={initialMetrics}>
					<WrappedComponent {...this.props} />
				</SafeAreaProvider>
			);
		}
	};
}
