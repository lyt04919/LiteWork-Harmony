import router from '@ohos.router';
import { Task } from '../utils/TaskStore';

@Component
export struct Profile {
  @StorageLink('globalTasks') tasks: Task[] = [];

  get completedCount(): number {
    return this.tasks.filter(t => t.status === '已完成').length;
  }

  get totalCount(): number {
    return this.tasks.length;
  }

  get completionRate(): number {
    if (this.totalCount === 0) return 0;
    return Math.round((this.completedCount / this.totalCount) * 100);
  }
  build() {
    Scroll() {
      Column() {
      // Header profile
      Column({ space: 8 }) {
        Image($r('app.media.startIcon')) // Mock avatar
          .width(80)
          .height(80)
          .borderRadius(40)
          .margin({ top: 40 })
          .border({ width: 2, color: '#0066FF' })
        Text('张伟').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('高级产品经理').fontSize(14).fontColor('#64748B')
      }.width('100%').alignItems(HorizontalAlign.Center)

      // Ring Chart Card
      Column() {
        Text('本周任务完成度').fontSize(16).fontColor('#1E293B').margin({ bottom: 24 }).width('100%').textAlign(TextAlign.Start)
        
        Stack() {
          Progress({ value: this.completedCount, total: this.totalCount === 0 ? 1 : this.totalCount, type: ProgressType.Ring })
            .width(160)
            .height(160)
            .color('#0066FF')
            .backgroundColor('#EDF2F7')
            .style({ strokeWidth: 16 })
          
          Column() {
            Text(`${this.completionRate}%`).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#0066FF')
            Text(`已完成 ${this.completedCount}/${this.totalCount}`).fontSize(12).fontColor('#64748B').margin({ top: 4 })
          }
        }
      }
      .width('90%')
      .padding(24)
      .margin({ top: 32, bottom: 24 })
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 4 })

      // Settings List
      Column({ space: 16 }) {
        this.SettingItem('我的任务', $r('app.media.startIcon'))
        this.SettingItem('系统设置', $r('app.media.startIcon'))
        this.SettingItem('AI智能客服', $r('app.media.startIcon'), '24小时在线协助', () => {
          router.pushUrl({ url: 'pages/AIChat' })
        })
      }.width('90%')
      }.width('100%')
    }.width('100%').height('100%').backgroundColor('#F5F7FA').scrollable(ScrollDirection.Vertical)
  }

  @Builder SettingItem(title: string, icon: Resource, subtitle?: string, action?: () => void) {
    Row() {
      Image(icon).width(40).height(40).borderRadius(8).backgroundColor('#E2E8F0').padding(8).margin({ right: 16 })
      Column() {
        Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1E293B')
        if (subtitle) {
          Text(subtitle).fontSize(12).fontColor('#0066FF').margin({ top: 4 })
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text('>').fontSize(18).fontColor('#94A3B8') // Chevron icon placeholder
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.02)', offsetY: 2 })
    .border({ width: 1, color: '#E2E8F0' })
    .onClick(() => {
      if (action) {
        action();
      }
    })
  }
}
