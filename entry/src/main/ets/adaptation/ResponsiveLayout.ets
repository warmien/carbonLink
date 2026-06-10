import { Breakpoint } from '../models/DeviceInfo';
import { DeviceAdapterManager } from './DeviceAdapterManager';

export class ResponsiveLayout {
  static getColumns(): number {
    const bp = DeviceAdapterManager.getCurrentBreakpoint();
    if (bp === Breakpoint.LG) return 4;
    if (bp === Breakpoint.MD) return 3;
    return 2;
  }

  static getContentPadding(): number {
    const bp = DeviceAdapterManager.getCurrentBreakpoint();
    if (bp === Breakpoint.LG) return 32;
    if (bp === Breakpoint.MD) return 24;
    return 16;
  }

  static getCardWidthPercent(): string {
    const bp = DeviceAdapterManager.getCurrentBreakpoint();
    if (bp === Breakpoint.LG) return '23%';
    if (bp === Breakpoint.MD) return '31%';
    return '48%';
  }

  static shouldUseSideNav(): boolean {
    return DeviceAdapterManager.isTabletOrLarger();
  }

  static getSideNavWidth(): number {
    const devType = DeviceAdapterManager.getDeviceType();
    if (devType === 'PC') return 280;
    if (devType === 'TABLET') return 240;
    return 0;
  }
}