import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Settings {
  @State isDarkMode: boolean = false;
  @State notificationsEnabled: boolean = true;

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 16 }).onClick(() => {
          router.back();
        })
        Text('系统设置').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1E293B')
      }.width('100%').padding(16).backgroundColor(Color.White)
      
      Divider().color('#E2E8F0').strokeWidth(1)

      Scroll() {
        Column({ space: 16 }) {
          
          // General Settings
          Text('通用设置').fontSize(14).fontColor('#94A3B8').width('100%').textAlign(TextAlign.Start).margin({ top: 16, bottom: 8 })
          
          Column() {
            this.ToggleSettingItem('深色模式', this.isDarkMode, (value: boolean) => { this.isDarkMode = value; })
            Divider().color('#E2E8F0').strokeWidth(1).margin({ left: 16, right: 16 })
            this.ToggleSettingItem('消息通知', this.notificationsEnabled, (value: boolean) => { this.notificationsEnabled = value; })
          }
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#E2E8F0' })

          // Advanced Settings
          Text('高级功能').fontSize(14).fontColor('#94A3B8').width('100%').textAlign(TextAlign.Start).margin({ top: 16, bottom: 8 })
          
          Column() {
            this.ActionSettingItem('清除缓存', '128 MB', () => {
              promptAction.showToast({ message: '缓存已清除', duration: 2000 });
            })
            Divider().color('#E2E8F0').strokeWidth(1).margin({ left: 16, right: 16 })
            this.ActionSettingItem('关于我们', 'v1.0.0', () => {
              promptAction.showToast({ message: 'LiteWork-Harmony v1.0.0', duration: 2000 });
            })
          }
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#E2E8F0' })

          // Logout
          Button('退出登录')
            .width('100%')
            .height(48)
            .backgroundColor('#FEF2F2')
            .fontColor('#EF4444')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .margin({ top: 32 })
            .onClick(() => {
              promptAction.showToast({ message: '演示版本暂不支持退出', duration: 2000 });
            })

        }.width('90%')
      }
      .layoutWeight(1)

    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }

  @Builder ToggleSettingItem(title: string, isOn: boolean, onChange: (value: boolean) => void) {
    Row() {
      Text(title).fontSize(16).fontColor('#1E293B').layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor('#0066FF')
        .onChange((value: boolean) => {
          onChange(value);
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder ActionSettingItem(title: string, subtitle: string, action: () => void) {
    Row() {
      Text(title).fontSize(16).fontColor('#1E293B').layoutWeight(1)
      Text(subtitle).fontSize(14).fontColor('#94A3B8').margin({ right: 8 })
      Text('>').fontSize(16).fontColor('#CBD5E1')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => action())
  }
}
