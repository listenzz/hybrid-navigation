import NativeEvent from '../NativeEvent';

interface IndexType {
	[index: string]: any;
}

export type ResultType = IndexType | null;
export type ResultEventListener<T extends ResultType> = (resultCode: number, data: T) => void;

export default class ResultEventHandler {
	private listenerRecords: Record<string, Record<number, Array<ResultEventListener<any>>>> = {};

	constructor() {}

	handleComponentResult() {
		NativeEvent.onResult(({ sceneId, requestCode, resultCode, resultData }) => {
			const listeners = this.listenerRecords[sceneId]?.[requestCode];
			if (listeners) {
				delete this.listenerRecords[sceneId][requestCode];
				listeners.forEach(l => l(resultCode, resultData));
			}
		});
	}

	private addResultEventListener(
		sceneId: string,
		requestCode: number,
		listener: ResultEventListener<any>,
	) {
		if (!this.listenerRecords[sceneId]) {
			this.listenerRecords[sceneId] = {};
		}

		if (!this.listenerRecords[sceneId][requestCode]) {
			this.listenerRecords[sceneId][requestCode] = [];
		}

		this.listenerRecords[sceneId][requestCode].push(listener);
	}

	private removeResultEventListener(sceneId: string, requestCode: number) {
		if (this.listenerRecords[sceneId]) {
			delete this.listenerRecords[sceneId][requestCode];
		}
	}

	invalidateResultEventListener(sceneId: string) {
		if (this.listenerRecords[sceneId]) {
			delete this.listenerRecords[sceneId];
		}
	}

	waitResult<T extends ResultType>(sceneId: string, requestCode: number): Promise<[number, T]> {
		return new Promise<[number, T]>(resolve => {
			const listener = (resultCode: number, data: T) => {
				this.removeResultEventListener(sceneId, requestCode);
				resolve([resultCode, data]);
			};
			this.addResultEventListener(sceneId, requestCode, listener);
		});
	}
}
