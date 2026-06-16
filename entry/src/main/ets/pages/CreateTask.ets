import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Task, TaskStore } from '../utils/TaskStore';

@Entry
@Component
struct CreateTask {
  @State title: string = '';
  @State description: string = '';
  @State assignee: string = '选择团队成员';
  @State dueDate: string = 'mm/dd/yyyy';

  private assignees: string[] = ['张伟', '李娜', '王强', '赵敏'];

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).onClick(() => {
          router.back();
        })
        Text('新建任务').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#0066FF').margin({ left: 16 }).layoutWeight(1)
        Text('帮助').fontSize(14).fontColor('#0066FF')
      }.width('100%').padding(16).alignItems(VerticalAlign.Center)
      
      Divider().color('#E2E8F0').strokeWidth(1)

      Scroll() {
        Column({ space: 24 }) {
          // Title
          Column({ space: 8 }) {
            Text('任务标题 *').fontSize(14).fontColor('#1E293B')
            TextInput({ placeholder: '输入任务名称...' })
              .height(48)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .border({ width: 1, color: '#CBD5E1' })
              .onChange((val: string) => this.title = val)
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Description
          Column({ space: 8 }) {
            Text('任务描述').fontSize(14).fontColor('#1E293B')
            TextArea({ placeholder: '添加详细的背景信息或步骤...' })
              .height(120)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .border({ width: 1, color: '#CBD5E1' })
              .onChange((val: string) => this.description = val)
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Assignee
          Column({ space: 8 }) {
            Text('分配负责人').fontSize(14).fontColor('#1E293B')
            Select(this.assignees.map(a => ({ value: a } as SelectOption)))
              .value(this.assignee)
              .font({ size: 16 })
              .selectedOptionFont({ size: 16 })
              .optionFont({ size: 16 })
              .width('100%')
              .height(48)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .border({ width: 1, color: '#CBD5E1' })
              .onSelect((index: number, value: string) => {
                this.assignee = value;
              })
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Due Date
          Column({ space: 8 }) {
            Text('截止日期').fontSize(14).fontColor('#1E293B')
            Row() {
              Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 12 })
              Text(this.dueDate).fontSize(16).fontColor(this.dueDate === 'mm/dd/yyyy' ? '#94A3B8' : '#1E293B').layoutWeight(1)
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
            .borderRadius(12)
            .border({ width: 1, color: '#CBD5E1' })
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2020-1-1"),
                end: new Date("2100-12-31"),
                selected: new Date(),
                onAccept: (value: DatePickerResult) => {
                  this.dueDate = `${value.year}-${(value.month as number) + 1}-${value.day}`;
                }
              })
            })
          }.alignItems(HorizontalAlign.Start).width('100%')

          Divider().color('#E2E8F0').strokeWidth(1).margin({ top: 16, bottom: 16 })

          // Buttons
          Row({ space: 16 }) {
            Button('取消')
              .backgroundColor(Color.White)
              .fontColor('#64748B')
              .border({ width: 1, color: '#CBD5E1' })
              .width(120)
              .height(44)
              .borderRadius(12)
              .onClick(() => router.back())
            
            Button('保存任务')
              .backgroundColor('#0066FF')
              .fontColor(Color.White)
              .width(120)
              .height(44)
              .borderRadius(12)
              .onClick(() => this.saveTask())
          }.width('100%').justifyContent(FlexAlign.End)

        }.padding(24)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }

  async saveTask() {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '任务标题不能为空', duration: 2000 });
      return;
    }
    const newTask: Task = {
      id: Date.now().toString(),
      title: this.title,
      description: this.description,
      assignee: this.assignee === '选择团队成员' ? '未分配' : this.assignee,
      dueDate: this.dueDate === 'mm/dd/yyyy' ? '无' : this.dueDate,
      priority: '普通', // Default
      status: '待办'
    };
    await TaskStore.getInstance().addTask(newTask);
    router.back();
  }
}
