import router from '@ohos.router';
import { Task } from '../utils/TaskStore';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MyTasks {
  @StorageLink('globalTasks') @Watch('onTasksChange') tasks: Task[] = [];
  @State filteredMyTasks: Task[] = [];
  
  // Mock current user
  private currentUser: string = '张伟';

  onTasksChange() {
    this.filteredMyTasks = (this.tasks || []).filter(t => t.assignee === this.currentUser);
  }

  aboutToAppear() {
    this.onTasksChange();
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 16 }).onClick(() => {
          router.back({ url: 'pages/Index' });
        })
        Text('我的任务').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      }.width('100%').padding(16).backgroundColor($r('app.color.bg_card'))
      
      Divider().color($r('app.color.border_default')).strokeWidth(1)

      if (this.filteredMyTasks.length === 0) {
        Column() {
          Text('暂无分配给我的任务').fontSize(16).fontColor($r('app.color.text_tertiary')).margin({ top: 40 })
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 16 }) {
          ForEach(this.filteredMyTasks, (item: Task) => {
            ListItem() {
              this.TaskCard(item)
            }
          })
        }
        .width('90%')
        .layoutWeight(1)
        .margin({ top: 16 })
      }
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }

  @Builder TaskCard(task: Task) {
    Column() {
      Row() {
        if (task.priority === '高优先级') {
          Text(task.priority).fontSize(12).fontColor($r('app.color.text_priority_high')).backgroundColor($r('app.color.bg_priority_high')).padding(4).borderRadius(4)
        } else {
          Text('普通').fontSize(12).fontColor($r('app.color.text_priority_normal')).backgroundColor($r('app.color.bg_priority_normal')).padding(4).borderRadius(4)
        }
        Blank()
        Text(task.status)
          .fontSize(12)
          .fontColor(task.status === '已完成' ? $r('app.color.text_status_completed') : (task.status === '进行中' ? $r('app.color.text_status_progress') : $r('app.color.text_secondary')))
      }.width('100%').margin({ bottom: 8 })

      Text(task.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
      if (task.description) {
        Text(task.description).fontSize(14).fontColor($r('app.color.text_secondary')).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 16 })
      }

      Row() {
        Text('截止时间: ' + task.dueDate).fontSize(14).fontColor($r('app.color.text_secondary'))
      }.width('100%').margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.border_default') })
    .shadow({ radius: 8, color: $r('app.color.shadow_card'), offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/CreateTask', params: { task: task } }, router.RouterMode.Standard);
    })
  }
}
