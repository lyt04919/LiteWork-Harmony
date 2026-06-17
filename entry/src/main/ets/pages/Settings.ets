import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Settings {
  @State isDarkMode: boolean = false;
  @State notificationsEnabled: boolean = true;




  aboutToAppear() {
    const stored = AppStorage.get<boolean>('darkMode');
    if (stored !== undefined) {
      this.isDarkMode = stored;
    } else {
      AppStorage.setOrCreate('darkMode', false);
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 16 }).onClick(() => {
          router.back({ url: 'pages/Index' });
        })
        Text('系统设置').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      }.width('100%').padding(16).backgroundColor($r('app.color.bg_card'))
      
      Divider().color($r('app.color.border_default')).strokeWidth(1)

      Scroll() {
        Column({ space: 16 }) {
          
          // General Settings
          Text('通用设置').fontSize(14).fontColor($r('app.color.text_tertiary')).width('100%').textAlign(TextAlign.Start).margin({ top: 16, bottom: 8 })
          
          Column() {
            Row() {
              Text('深色模式').fontSize(16).fontColor($r('app.color.text_primary')).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
                .selectedColor($r('app.color.accent'))
                .onChange((value: boolean) => {
                  this.isDarkMode = value;
                  this.setDarkMode(value);
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            Divider().color($r('app.color.border_default')).strokeWidth(1).margin({ left: 16, right: 16 })
            this.ToggleSettingItem('消息通知', this.notificationsEnabled, (value: boolean) => { this.notificationsEnabled = value; })
          }
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(12)
          .border({ width: 1, color: $r('app.color.border_default') })

          // Advanced Settings
          Text('高级功能').fontSize(14).fontColor($r('app.color.text_tertiary')).width('100%').textAlign(TextAlign.Start).margin({ top: 16, bottom: 8 })
          
          Column() {
            this.ActionSettingItem('清除缓存', '128 MB', () => {
              promptAction.showToast({ message: '缓存已清除', duration: 2000 });
            })
            Divider().color($r('app.color.border_default')).strokeWidth(1).margin({ left: 16, right: 16 })
            this.ActionSettingItem('关于我们', 'v1.0.0', () => {
              promptAction.showToast({ message: 'LiteWork-Harmony v1.0.0', duration: 2000 });
            })
          }
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(12)
          .border({ width: 1, color: $r('app.color.border_default') })

          // Logout
          Button('退出登录')
            .width('100%')
            .height(48)
            .backgroundColor($r('app.color.bg_logout'))
            .fontColor($r('app.color.text_logout'))
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

    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }

  setDarkMode(isDark: boolean) {
    try {
      AppStorage.setOrCreate('darkMode', isDark);
      getContext().getApplicationContext()
        .setColorMode(isDark ? 0 : 1);
    } catch (err) {
      console.error('Failed to set dark mode:', JSON.stringify(err));
    }
  }

  @Builder ToggleSettingItem(title: string, isOn: boolean, onChange: (value: boolean) => void) {
    Row() {
      Text(title).fontSize(16).fontColor($r('app.color.text_primary')).layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor($r('app.color.accent'))
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
      Text(title).fontSize(16).fontColor($r('app.color.text_primary')).layoutWeight(1)
      Text(subtitle).fontSize(14).fontColor($r('app.color.text_tertiary')).margin({ right: 8 })
      Text('>').fontSize(16).fontColor($r('app.color.text_tertiary'))
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => action())
  }
}
