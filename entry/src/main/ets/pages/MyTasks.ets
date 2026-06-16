import router from '@ohos.router';
import { Task } from '../utils/TaskStore';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MyTasks {
  @StorageLink('globalTasks') tasks: Task[] = [];
  
  // Mock current user
  private currentUser: string = '张伟';

  get myTasks(): Task[] {
    return (this.tasks || []).filter(t => t.assignee === this.currentUser);
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 16 }).onClick(() => {
          router.back();
        })
        Text('我的任务').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1E293B')
      }.width('100%').padding(16).backgroundColor(Color.White)
      
      Divider().color('#E2E8F0').strokeWidth(1)

      if (this.myTasks.length === 0) {
        Column() {
          Text('暂无分配给我的任务').fontSize(16).fontColor('#94A3B8').margin({ top: 40 })
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 16 }) {
          ForEach(this.myTasks, (item: Task) => {
            ListItem() {
              this.TaskCard(item)
            }
          })
        }
        .width('90%')
        .layoutWeight(1)
        .margin({ top: 16 })
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }

  @Builder TaskCard(task: Task) {
    Column() {
      Row() {
        if (task.priority === '高优先级') {
          Text(task.priority).fontSize(12).fontColor('#ba1a1a').backgroundColor('#ffdad6').padding(4).borderRadius(4)
        } else {
          Text('普通').fontSize(12).fontColor('#0054d6').backgroundColor('#dae1ff').padding(4).borderRadius(4)
        }
        Blank()
        Text(task.status)
          .fontSize(12)
          .fontColor(task.status === '已完成' ? '#10B981' : (task.status === '进行中' ? '#F59E0B' : '#64748B'))
      }.width('100%').margin({ bottom: 8 })

      Text(task.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ bottom: 8 })
      if (task.description) {
        Text(task.description).fontSize(14).fontColor('#64748B').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 16 })
      }

      Row() {
        Text('截止时间: ' + task.dueDate).fontSize(14).fontColor('#64748B')
      }.width('100%').margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width: 1, color: '#E2E8F0' })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .onClick(() => {
      promptAction.showToast({ message: '任务详情开发中...', duration: 2000 })
    })
  }
}
