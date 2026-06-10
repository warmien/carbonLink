import { deviceInfo } from '@kit.BasicServicesKit';
import { DeviceType, Breakpoint } from '../models/DeviceInfo';

export class DeviceAdapterManager {
  private static cachedDeviceType: DeviceType = DeviceType.PHONE;
  private static cachedScreenWidth: number = 360;
  private static cachedScreenHeight: number = 640;
  private static cachedIsRound: boolean = false;
  private static initialized: boolean = false;

  static init(): void {
    if (DeviceAdapterManager.initialized) return;
    try {
      const devType = deviceInfo.deviceType;
      if (devType === 'phone') {
        DeviceAdapterManager.cachedDeviceType = DeviceType.PHONE;
      } else if (devType === 'watch' || devType === 'wearable') {
        DeviceAdapterManager.cachedDeviceType = DeviceType.WATCH;
      } else if (devType === 'tablet') {
        DeviceAdapterManager.cachedDeviceType = DeviceType.TABLET;
      } else if (devType === '2in1' || devType === 'pc') {
        DeviceAdapterManager.cachedDeviceType = DeviceType.PC;
      } else {
        DeviceAdapterManager.cachedDeviceType = DeviceType.PHONE;
      }
    } catch (e) {
      DeviceAdapterManager.cachedDeviceType = DeviceType.PHONE;
    }
    DeviceAdapterManager.initialized = true;
  }

  static getDeviceType(): DeviceType {
    DeviceAdapterManager.init();
    return DeviceAdapterManager.cachedDeviceType;
  }

  static getScreenWidth(): number {
    return DeviceAdapterManager.cachedScreenWidth;
  }

  static getScreenHeight(): number {
    return DeviceAdapterManager.cachedScreenHeight;
  }

  static isRoundScreen(): boolean {
    return DeviceAdapterManager.cachedIsRound;
  }

  static hasCapability(capability: string): boolean {
    const devType = DeviceAdapterManager.getDeviceType();
    if (capability === 'camera') {
      return devType !== DeviceType.WATCH;
    }
    if (capability === 'location') {
      return devType !== DeviceType.WATCH;
    }
    if (capability === 'notification') {
      return devType !== DeviceType.WATCH;
    }
    return true;
  }

  static getCurrentBreakpoint(): Breakpoint {
    const width = DeviceAdapterManager.getScreenWidth();
    if (width >= 840) return Breakpoint.LG;
    if (width >= 600) return Breakpoint.MD;
    return Breakpoint.SM;
  }

  static isTabletOrLarger(): boolean {
    const devType = DeviceAdapterManager.getDeviceType();
    return devType === DeviceType.TABLET || devType === DeviceType.PC;
  }
}