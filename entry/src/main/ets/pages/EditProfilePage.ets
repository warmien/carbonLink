import { router } from '@kit.ArkUI';
import { HttpService, ApiResponse } from '../services/HttpService';
import { AuthManager } from '../services/AuthManager';
import { ObsService } from '../services/ObsService';
import { ImagePickerService } from '../services/ImagePickerService';
import { AppConstants } from '../constants/AppConstants';
import { ThemeManager } from '../theme/ThemeManager';
import { promptAction } from '@kit.ArkUI';


@Entry
@Component
struct EditProfilePage {
  @State nickname: string = '';
  @State avatar: string = '';
  @State gender: string = '';
  @State bio: string = '';
  @State location: string = '';
  @State phone: string = '';
  @State joinDate: string = '';
  @State creditScore: number = 100;
  @State creditLevel: string = '良好';
  @State isSaving: boolean = false;
  @State showGenderPicker: boolean = false;
  @State showLocationPicker: boolean = false;
  @State showLogoutConfirm: boolean = false;
  @State selectedProvince: string = '';
  @State selectedCity: string = '';
  @State detailAddress: string = '';
  @State pickerProvinceIndex: number = 0;
  @State pickerCityIndex: number = 0;

  async aboutToAppear(): Promise<void> {
    const userJson: string = AppStorage.get<string>('currentUser') || '';
    if (userJson.length > 0) {
      try {
        const userObj: Record<string, string | number> = JSON.parse(userJson) as Record<string, string | number>;
        this.nickname = userObj['nickname'] as string;
        this.avatar = userObj['avatar'] as string;
        this.gender = userObj['gender'] as string;
        this.bio = userObj['bio'] as string;
        this.location = userObj['location'] as string;
        if (this.location.length > 0) {
          const parts: string[] = this.location.split(' ');
          if (parts.length >= 2) {
            this.selectedProvince = parts[0];
            this.selectedCity = parts[1];
            if (parts.length >= 3) {
              this.detailAddress = parts.slice(2).join(' ');
            }
          } else {
            this.detailAddress = this.location;
          }
        }
        this.phone = userObj['phone'] as string;
        this.joinDate = userObj['joinDate'] as string;
        const csVal = userObj['creditScore'];
        this.creditScore = typeof csVal === 'number' ? csVal : 0;
        this.creditLevel = userObj['creditLevel'] as string;
      } catch (err) {
        console.error(`[EditProfilePage] parse user failed: ${(err as Error).message}`);
      }
    }
  }

  async handleSave(): Promise<void> {
    if (this.isSaving) {
      return;
    }

    if (this.nickname.length < 2 || this.nickname.length > 20) {
      promptAction.showToast({ message: '昵称长度2-20字符' });
      return;
    }

    if (this.bio.length > 200) {
      promptAction.showToast({ message: '简介最多200字符' });
      return;
    }

    this.isSaving = true;

    let locationStr: string = '';
    if (this.selectedProvince.length > 0) {
      locationStr = this.selectedProvince;
    }
    if (this.selectedCity.length > 0) {
      locationStr += ' ' + this.selectedCity;
    }
    if (this.detailAddress.length > 0) {
      locationStr += ' ' + this.detailAddress;
    }
    this.location = locationStr.trim();

    const reqBody: Record<string, string | number | object> = {
      'nickname': this.nickname,
      'avatar': this.avatar,
      'gender': this.gender,
      'bio': this.bio,
      'location': this.location
    };

    const response: ApiResponse = await HttpService.PUT('/profile', reqBody);

    this.isSaving = false;

    if (response.code === 0 && response.data !== null) {
      AppStorage.setOrCreate('currentUser', JSON.stringify(response.data));
      promptAction.showToast({ message: '保存成功' });
      router.back();
    } else {
      promptAction.showToast({ message: response.message || '保存失败' });
    }
  }

  getGenderLabel(gender: string): string {
    if (gender === 'male') {
      return '男';
    }
    if (gender === 'female') {
      return '女';
    }
    return '未设置';
  }

  getProvinces(): string[] {
    return [
      '北京', '天津', '上海', '重庆',
      '河北', '山西', '辽宁', '吉林', '黑龙江',
      '江苏', '浙江', '安徽', '福建', '江西', '山东',
      '河南', '湖北', '湖南', '广东', '海南',
      '四川', '贵州', '云南', '陕西', '甘肃',
      '青海', '台湾', '内蒙古', '广西', '西藏',
      '宁夏', '新疆', '香港', '澳门'
    ];
  }

  getCities(provinceIndex: number): string[] {
    const cityData: Record<string, string[]> = {
      '北京': ['东城区', '西城区', '朝阳区', '海淀区', '丰台区', '石景山区', '通州区', '顺义区', '大兴区', '昌平区'],
      '天津': ['和平区', '河东区', '河西区', '南开区', '河北区', '红桥区', '滨海新区', '东丽区', '西青区', '津南区'],
      '上海': ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '浦东新区', '闵行区', '宝山区'],
      '重庆': ['渝中区', '大渡口区', '江北区', '沙坪坝区', '九龙坡区', '南岸区', '北碚区', '渝北区', '巴南区'],
      '河北': ['石家庄', '唐山', '秦皇岛', '邯郸', '邢台', '保定', '张家口', '承德', '沧州', '廊坊', '衡水'],
      '山西': ['太原', '大同', '阳泉', '长治', '晋城', '朔州', '晋中', '运城', '忻州', '临汾', '吕梁'],
      '辽宁': ['沈阳', '大连', '鞍山', '抚顺', '本溪', '丹东', '锦州', '营口', '阜新', '辽阳', '盘锦', '铁岭'],
      '吉林': ['长春', '吉林', '四平', '辽源', '通化', '白山', '松原', '白城', '延边'],
      '黑龙江': ['哈尔滨', '齐齐哈尔', '牡丹江', '佳木斯', '大庆', '鸡西', '双鸭山', '伊春', '七台河', '鹤岗', '绥化'],
      '江苏': ['南京', '苏州', '无锡', '常州', '徐州', '南通', '连云港', '淮安', '盐城', '扬州', '镇江', '泰州', '宿迁'],
      '浙江': ['杭州', '宁波', '温州', '嘉兴', '湖州', '绍兴', '金华', '衢州', '舟山', '台州', '丽水'],
      '安徽': ['合肥', '芜湖', '蚌埠', '淮南', '马鞍山', '淮北', '铜陵', '安庆', '黄山', '滁州', '阜阳', '宿州'],
      '福建': ['福州', '厦门', '莆田', '三明', '泉州', '漳州', '南平', '龙岩', '宁德'],
      '江西': ['南昌', '景德镇', '萍乡', '九江', '新余', '鹰潭', '赣州', '吉安', '宜春', '抚州', '上饶'],
      '山东': ['济南', '青岛', '淄博', '枣庄', '东营', '烟台', '潍坊', '济宁', '泰安', '威海', '日照', '临沂'],
      '河南': ['郑州', '开封', '洛阳', '平顶山', '安阳', '鹤壁', '新乡', '焦作', '濮阳', '许昌', '漯河', '南阳'],
      '湖北': ['武汉', '黄石', '十堰', '宜昌', '襄阳', '鄂州', '荆门', '孝感', '荆州', '黄冈', '咸宁', '随州'],
      '湖南': ['长沙', '株洲', '湘潭', '衡阳', '邵阳', '岳阳', '常德', '张家界', '益阳', '郴州', '永州', '怀化'],
      '广东': ['广州', '深圳', '珠海', '汕头', '佛山', '韶关', '湛江', '肇庆', '江门', '茂名', '惠州', '东莞', '中山'],
      '海南': ['海口', '三亚', '三沙', '儋州'],
      '四川': ['成都', '自贡', '攀枝花', '泸州', '德阳', '绵阳', '广元', '遂宁', '内江', '乐山', '南充', '宜宾'],
      '贵州': ['贵阳', '六盘水', '遵义', '安顺', '毕节', '铜仁'],
      '云南': ['昆明', '曲靖', '玉溪', '保山', '昭通', '丽江', '普洱', '临沧', '大理', '红河'],
      '陕西': ['西安', '铜川', '宝鸡', '咸阳', '渭南', '延安', '汉中', '榆林', '安康', '商洛'],
      '甘肃': ['兰州', '嘉峪关', '金昌', '白银', '天水', '武威', '张掖', '平凉', '酒泉', '庆阳', '定西'],
      '青海': ['西宁', '海东', '海北', '黄南', '海南', '果洛', '玉树', '海西'],
      '台湾': ['台北', '台中', '高雄', '台南', '新竹', '基隆'],
      '内蒙古': ['呼和浩特', '包头', '乌海', '赤峰', '通辽', '鄂尔多斯', '呼伦贝尔', '巴彦淖尔', '乌兰察布'],
      '广西': ['南宁', '柳州', '桂林', '梧州', '北海', '防城港', '钦州', '贵港', '玉林', '百色'],
      '西藏': ['拉萨', '日喀则', '昌都', '林芝', '山南', '那曲'],
      '宁夏': ['银川', '石嘴山', '吴忠', '固原', '中卫'],
      '新疆': ['乌鲁木齐', '克拉玛依', '吐鲁番', '哈密', '昌吉', '博尔塔拉', '巴音郭楞', '阿克苏', '喀什', '和田'],
      '香港': ['中西区', '湾仔区', '东区', '南区', '油尖旺区', '深水埗区', '九龙城区', '黄大仙区', '观塘区'],
      '澳门': ['花地玛堂区', '花王堂区', '望德堂区', '大堂区', '风顺堂区', '嘉模堂区', '路氹填海区', '圣方济各堂区']
    };
    const provinces: string[] = this.getProvinces();
    if (provinceIndex >= 0 && provinceIndex < provinces.length) {
      const province: string = provinces[provinceIndex];
      const cities: string[] | undefined = cityData[province];
      if (cities !== undefined) {
        return cities;
      }
    }
    return [];
  }

  build() {
    Stack() {
      Column() {

        Column().height(AppConstants.STATUS_BAR_HEIGHT).width('100%')

        Row() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor('#333333')
            .onClick(() => {
              router.back();
            })
            .scale({ x: 1, y: 1 })
            .animation({ duration: 100, curve: Curve.EaseOut })

          Text('编辑资料')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ left: 24 })

          Text('保存')
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(ThemeManager.COLOR_PRIMARY)
            .borderRadius(ThemeManager.RADIUS_MD)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .onClick(() => {
              this.handleSave();
            })
            .scale({ x: 1, y: 1 })
            .animation({ duration: 100, curve: Curve.EaseOut })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            Column() {
              Stack() {
                Column()
                  .width(80)
                  .height(80)
                  .borderRadius(40)
                  .backgroundColor('#F0F0F0')

                if (this.avatar.length > 0) {
                  Image(this.avatar)
                    .width(80)
                    .height(80)
                    .borderRadius(40)
                    .objectFit(ImageFit.Cover)
                } else {
                  Image($r('sys.symbol.person_crop_circle_fill'))
                    .width(40)
                    .height(40)
                    .fillColor('#CCCCCC')
                }

                Column() {
                  Image($r('sys.symbol.chevron_right'))
                    .width(22)
                    .height(22)
                    .fillColor(Color.White)
                }
                .width(24)
                .height(24)
                .borderRadius(ThemeManager.RADIUS_MD)
                .backgroundColor(ThemeManager.COLOR_PRIMARY)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .position({ x: 56, y: 56 })
              }
              .width(80)
              .height(80)
              .margin({ top: 20, bottom: 16 })
              .onClick(async () => {
                const uris = await ImagePickerService.selectFromGallery(1);
                if (uris.length > 0) {
                  promptAction.showToast({ message: '正在上传头像...' });
                  const url = await ObsService.uploadImage(uris[0]);
                  if (url) {
                    this.avatar = url;
                    promptAction.showToast({ message: '头像上传成功' });
                  } else {
                    promptAction.showToast({ message: '头像上传失败' });
                  }
                }
              })

              Text('点击更换头像')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ bottom: 16 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)

            Column() {
              Row() {
                Text('昵称')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(60)

                TextInput({ placeholder: '请输入昵称', text: this.nickname })
                  .fontSize(15)
                  .fontColor('#333333')
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
                  .maxLength(20)
                  .onChange((value: string) => {
                    this.nickname = value;
                  })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)

              Row()
                .width('100%')
                .height(0.5)
                .backgroundColor('#F0F0F0')
                .margin({ left: 16 })

              Row() {
                Text('性别')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(60)

                Blank()

                Text(this.getGenderLabel(this.gender))
                  .fontSize(15)
                  .fontColor(this.gender.length > 0 ? '#333333' : '#CCCCCC')

                Image($r('sys.symbol.chevron_right'))
                  .width(14)
                  .height(14)
                  .fillColor('#CCCCCC')
                  .margin({ left: 4 })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.showGenderPicker = true;
              })

              Row()
                .width('100%')
                .height(0.5)
                .backgroundColor('#F0F0F0')
                .margin({ left: 16 })

              Row() {
                Text('简介')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(60)

                TextInput({ placeholder: '写点什么介绍自己吧', text: this.bio })
                  .fontSize(15)
                  .fontColor('#333333')
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
                  .maxLength(200)
                  .onChange((value: string) => {
                    this.bio = value;
                  })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)

              Row()
                .width('100%')
                .height(0.5)
                .backgroundColor('#F0F0F0')
                .margin({ left: 16 })

              Row() {
                Text('地区')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(60)

                Blank()

                Text(this.selectedProvince.length > 0 ? `${this.selectedProvince} ${this.selectedCity}` : '请选择地区')
                  .fontSize(15)
                  .fontColor(this.selectedProvince.length > 0 ? '#333333' : '#CCCCCC')

                Image($r('sys.symbol.chevron_right'))
                  .width(14)
                  .height(14)
                  .fillColor('#CCCCCC')
                  .margin({ left: 4 })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.showLocationPicker = true;
              })

              Row()
                .width('100%')
                .height(0.5)
                .backgroundColor('#F0F0F0')
                .margin({ left: 16 })

              Row() {
                Text('详细地址')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(70)

                TextInput({ placeholder: '请输入详细地址', text: this.detailAddress })
                  .fontSize(15)
                  .fontColor('#333333')
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
                  .maxLength(100)
                  .onChange((value: string) => {
                    this.detailAddress = value;
                  })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(ThemeManager.RADIUS_MD)
            .margin({ top: 12 })

            Column() {
              Row() {
                Text('手机号')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(60)

                Blank()

                Text(this.phone.length > 0 ? this.phone.substring(0, 3) + '****' + this.phone.substring(7) : '')
                  .fontSize(15)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)

              Row()
                .width('100%')
                .height(0.5)
                .backgroundColor('#F0F0F0')
                .margin({ left: 16 })

              Row() {
                Text('信用积分')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(80)

                Blank()

                Text(this.creditScore.toString())
                  .fontSize(15)
                  .fontColor('#999999')
                  .margin({ right: 4 })

                Text(this.creditLevel)
                  .fontSize(12)
                  .fontColor(ThemeManager.COLOR_PRIMARY)
                  .backgroundColor('#E8F8F0')
                  .borderRadius(ThemeManager.RADIUS_SM)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)

              Row()
                .width('100%')
                .height(0.5)
                .backgroundColor('#F0F0F0')
                .margin({ left: 16 })

              Row() {
                Text('注册时间')
                  .fontSize(15)
                  .fontColor('#333333')
                  .width(80)

                Blank()

                Text(this.joinDate)
                  .fontSize(15)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(ThemeManager.RADIUS_MD)
            .margin({ top: 12 })

            Blank().height(16)

            Button('退出登录')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#FF4D4F')
              .borderRadius(ThemeManager.RADIUS_LG)
              .type(ButtonType.Normal)
              .onClick(() => {
                this.showLogoutConfirm = true;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')



      if (this.showGenderPicker) {
        Column() {
          Column() {
            Text('选择性别')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 20, bottom: 12 })

            Row() {
              ForEach(['男', '女', '未设置'], (item: string) => {
                Column() {
                  Text(item)
                    .fontSize(15)
                    .fontColor(this.getGenderLabel(this.gender) === item ? ThemeManager.COLOR_PRIMARY : '#333333')
                    .fontWeight(this.getGenderLabel(this.gender) === item ? FontWeight.Medium : FontWeight.Normal)
                }
                .layoutWeight(1)
                .height(48)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  if (item === '男') {
                    this.gender = 'male';
                  } else if (item === '女') {
                    this.gender = 'female';
                  } else {
                    this.gender = '';
                  }
                  this.showGenderPicker = false;
                })
              })
            }
            .width('100%')

            Text('取消')
              .fontSize(15)
              .fontColor('#999999')
              .width('100%')
              .textAlign(TextAlign.Center)
              .height(48)
              .onClick(() => {
                this.showGenderPicker = false;
              })
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showGenderPicker = false;
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
      }

      if (this.showLocationPicker) {
        Column() {
          Blank().layoutWeight(1)

          Column() {
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor('#666666')
                .padding({ left: 20, top: 16, bottom: 8 })
                .onClick(() => {
                  this.showLocationPicker = false;
                })

              Blank()

              Text('选择地区')
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text('确定')
                .fontSize(16)
                .fontColor(ThemeManager.COLOR_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .padding({ right: 20, top: 16, bottom: 8 })
                .onClick(() => {
                  const provinces = this.getProvinces();
                  const cities = this.getCities(this.pickerProvinceIndex);
                  if (provinces.length > 0) {
                    this.selectedProvince = provinces[this.pickerProvinceIndex];
                  }
                  if (cities.length > 0) {
                    this.selectedCity = cities[this.pickerCityIndex];
                  }
                  this.showLocationPicker = false;
                })
            }
            .width('100%')
            .padding({ left: 8, right: 8 })

            Row()
              .width('100%')
              .height(0.5)
              .backgroundColor('#E8E8E8')
              .margin({ top: 4, bottom: 4 })

            Row() {
              Column() {
                List() {
                  ForEach(this.getProvinces(), (province: string) => {
                    ListItem() {
                      Text(province)
                        .fontSize(15)
                        .fontColor(this.pickerProvinceIndex === this.getProvinces().indexOf(province) ? ThemeManager.COLOR_PRIMARY : '#333333')
                        .fontWeight(this.pickerProvinceIndex === this.getProvinces().indexOf(province) ? FontWeight.Medium : FontWeight.Normal)
                        .width('100%')
                        .height(44)
                        .textAlign(TextAlign.Center)
                        .borderRadius(ThemeManager.RADIUS_SM)
                        .backgroundColor(this.pickerProvinceIndex === this.getProvinces().indexOf(province) ? '#E8F8F0' : Color.Transparent)
                        .onClick(() => {
                          this.pickerProvinceIndex = this.getProvinces().indexOf(province);
                          this.pickerCityIndex = 0;
                        })
                    }
                  })
                }
                .width('100%')
                .layoutWeight(1)
                .scrollBar(BarState.Off)
              }
              .layoutWeight(1)

              Column()
                .width(0.5)
                .height('100%')
                .backgroundColor('#E8E8E8')

              Column() {
                List() {
                  ForEach(this.getCities(this.pickerProvinceIndex), (city: string) => {
                    ListItem() {
                      Text(city)
                        .fontSize(15)
                        .fontColor(this.pickerCityIndex === this.getCities(this.pickerProvinceIndex).indexOf(city) ? ThemeManager.COLOR_PRIMARY : '#333333')
                        .fontWeight(this.pickerCityIndex === this.getCities(this.pickerProvinceIndex).indexOf(city) ? FontWeight.Medium : FontWeight.Normal)
                        .width('100%')
                        .height(44)
                        .textAlign(TextAlign.Center)
                        .borderRadius(ThemeManager.RADIUS_SM)
                        .backgroundColor(this.pickerCityIndex === this.getCities(this.pickerProvinceIndex).indexOf(city) ? '#E8F8F0' : Color.Transparent)
                        .onClick(() => {
                          this.pickerCityIndex = this.getCities(this.pickerProvinceIndex).indexOf(city);
                        })
                    }
                  })
                }
                .width('100%')
                .layoutWeight(1)
                .scrollBar(BarState.Off)
              }
              .layoutWeight(1)
            }
            .width('100%')
            .height(280)
            .padding({ left: 8, right: 8 })

            Column().height(34).width('100%')
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: ThemeManager.RADIUS_LG, topRight: ThemeManager.RADIUS_LG })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .onClick(() => {
          this.showLocationPicker = false;
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
      }

      if (this.showLogoutConfirm) {
        Column() {
          Blank().layoutWeight(1)

          Column() {
            Text('退出登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 24, bottom: 8 })

            Text('确定要退出当前账号吗？')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ bottom: 24 })

            Row() {
              Button('取消')
                .width('48%')
                .height(44)
                .fontSize(16)
                .fontColor('#333333')
                .backgroundColor('#F5F5F5')
                .borderRadius(ThemeManager.RADIUS_LG)
                .type(ButtonType.Normal)
                .onClick(() => {
                  this.showLogoutConfirm = false;
                })

              Button('退出')
                .width('48%')
                .height(44)
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor('#FF4D4F')
                .borderRadius(ThemeManager.RADIUS_LG)
                .type(ButtonType.Normal)
                .onClick(() => {
                  this.showLogoutConfirm = false;
                  AuthManager.logout();
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 20, right: 20 })

            Column().height(34).width('100%')
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: ThemeManager.RADIUS_LG, topRight: ThemeManager.RADIUS_LG })
          .padding({ bottom: 8 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .onClick(() => {
          this.showLogoutConfirm = false;
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))
      }
    }
    .width('100%')
    .height('100%')
  }
}