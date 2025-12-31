import { useContext, useEffect, useEffectEvent } from 'react';
import Navigation from './Navigation';
import { Navigator, NavigationContext } from './Navigator';

export function useNavigator(): Navigator {
	return useContext<Navigator>(NavigationContext);
}

export function useVisibleEffect<T extends Function>(callback: T) {
	const navigator = useNavigator();
	const event = useEffectEvent(callback);

	useEffect(() => {
		let destructor: (() => void) | undefined;
		const subscription = Navigation.addVisibilityEventListener(navigator.sceneId, v => {
			if (v === 'visible') {
				destructor = event();
			} else {
				destructor && destructor();
				destructor = undefined;
			}
		});
		return () => {
			subscription.remove();
			destructor && destructor();
		};
	}, [navigator]);
}
