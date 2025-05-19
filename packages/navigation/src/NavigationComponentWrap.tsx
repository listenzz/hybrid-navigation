import React, {useEffect} from 'react';
import type {NavigationItem} from './Options';
import {Navigator, NavigationContext} from './Navigator';
import Navigation from './Navigation';

export interface NavigationProps {
	navigator: Navigator;
	sceneId: string;
}

interface NativeProps {
	sceneId: string;
}

function getDisplayName(WrappedComponent: React.ComponentType<any>) {
	return WrappedComponent.displayName || WrappedComponent.name || 'Component';
}

export function withNavigation(moduleName: string) {
	return function (WrappedComponent: React.ComponentType<any>) {
		const FC = React.forwardRef(
			(props: NativeProps, ref: React.Ref<React.ComponentType<any>>) => {
				const {sceneId} = props;

				const navigator = Navigator.of(sceneId);
				if (navigator.moduleName === undefined) {
					navigator.moduleName = moduleName;
				}

				useEffect(() => {
					Navigation.signalFirstRenderComplete(sceneId);
					return () => {
						Navigator.unmount(sceneId);
					};
				}, [sceneId]);

				const injected = {
					navigator,
				};

				return (
					<NavigationContext.Provider value={navigator}>
						<WrappedComponent ref={ref} {...props} {...injected} />
					</NavigationContext.Provider>
				);
			},
		);

		FC.displayName = `withNavigation(${getDisplayName(WrappedComponent)})`;
		return FC;
	};
}

export function withNavigationItem(item: NavigationItem) {
	return function (WrappedComponent: React.ComponentType<any>): React.ComponentType<any> {
		let navigationItem = (WrappedComponent as any).navigationItem;
		if (navigationItem) {
			(WrappedComponent as any).navigationItem = {
				...navigationItem,
				...item,
			};
		} else {
			(WrappedComponent as any).navigationItem = item;
		}
		return WrappedComponent;
	};
}
