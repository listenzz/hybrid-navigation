import { Navigator } from './Navigator';
export interface BindOptions {
    inLayout?: boolean;
    sceneId?: string | undefined;
    navigatorFactory?: (sceneId: string) => Navigator;
}
declare function bindBarButtonItemClickEvent(item?: {}, options?: BindOptions): void;
declare function removeBarButtonItemClickEvent(sceneId: string): void;
export { bindBarButtonItemClickEvent, removeBarButtonItemClickEvent };
