import React, { ComponentType } from 'react';
import { Platform } from 'react-native';
import {
	SafeAreaProvider,
	SafeAreaInsetsContext,
	useSafeAreaInsets,
	initialWindowMetrics,
} from 'react-native-safe-area-context';

function TabBarInsetAdjuster({
	tabBarInset,
	children,
}: {
	tabBarInset: number;
	children: React.ReactNode;
}) {
	const insets = useSafeAreaInsets();
	const adjusted = React.useMemo(
		() => ({ ...insets, bottom: insets.bottom + tabBarInset }),
		[insets, tabBarInset],
	);
	return (
		<SafeAreaInsetsContext.Provider value={adjusted}>{children}</SafeAreaInsetsContext.Provider>
	);
}

export default function SafeAreaContextHOC(WrappedComponent: ComponentType<any>) {
	return class SafeAreaContextProvider extends React.Component<any> {
		static navigationItem = (WrappedComponent as any).navigationItem;

		render() {
			const { tabBarInset, ...rest } = this.props;
			const needsAdjust =
				Platform.OS === 'android' && typeof tabBarInset === 'number' && tabBarInset > 0;

			return (
				<SafeAreaProvider initialMetrics={initialWindowMetrics ?? undefined}>
					{needsAdjust ? (
						<TabBarInsetAdjuster tabBarInset={tabBarInset}>
							<WrappedComponent {...rest} />
						</TabBarInsetAdjuster>
					) : (
						<WrappedComponent {...rest} />
					)}
				</SafeAreaProvider>
			);
		}
	};
}
