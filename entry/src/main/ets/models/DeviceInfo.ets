export class DeviceInfoModel {
  deviceType: DeviceType = DeviceType.PHONE;
  screenWidth: number = 360;
  screenHeight: number = 640;
  isRoundScreen: boolean = false;
  supportedCapabilities: string[] = [];
}

export enum DeviceType {
  PHONE = 'PHONE',
  WATCH = 'WATCH',
  TABLET = 'TABLET',
  PC = 'PC'
}

export enum Breakpoint {
  SM = 'sm',
  MD = 'md',
  LG = 'lg'
}