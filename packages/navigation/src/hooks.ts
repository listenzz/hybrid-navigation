import React, { useContext, useEffect, useState } from 'react';
import Navigation from './Navigation';
import { Navigator, NavigationContext } from './Navigator';

export function useNavigator(): Navigator {
	return useContext<Navigator>(NavigationContext);
}

export function useVisibility() {
	const navigator = useNavigator();
	const [visibility, setVisibility] = useState(navigator.visibility);

	useEffect(() => {
		const subscription = Navigation.addVisibilityEventListener(navigator.sceneId, v => {
			setVisibility(v);
		});
		return () => subscription.remove();
	}, [navigator]);

	return visibility;
}

export function useVisible() {
	const visibility = useVisibility();
	return visibility === 'visible';
}

export function useVisibleEffect(effect: React.EffectCallback) {
	const visible = useVisible();
	useEffect(() => {
		if (!visible) {
			return;
		}
		const destructor = effect();
		return () => destructor && destructor();
	}, [effect, visible]);
}
