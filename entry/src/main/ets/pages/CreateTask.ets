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
  @State priority: string = '普通';
  @State status: string = '待办';
  @State isEdit: boolean = false;
  @State editTaskId: string = '';

  private assignees: string[] = ['张伟', '李娜', '王强', '赵敏'];
  private priorities: string[] = ['普通', '高优先级'];
  private statuses: string[] = ['待办', '进行中', '已完成'];

  aboutToAppear() {
    let params = router.getParams() as Record<string, Object>;
    if (params && params['task']) {
      let task = params['task'] as Task;
      this.isEdit = true;
      this.editTaskId = task.id;
      this.title = task.title;
      this.description = task.description || '';
      this.assignee = task.assignee;
      this.dueDate = task.dueDate;
      this.priority = task.priority;
      this.status = task.status;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).onClick(() => {
          router.back({ url: 'pages/Index' });
        })
        Text(this.isEdit ? '编辑任务' : '新建任务').fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.accent')).margin({ left: 16 }).layoutWeight(1)
        Text('帮助').fontSize(14).fontColor($r('app.color.accent'))
      }.width('100%').padding(16).alignItems(VerticalAlign.Center)
      
      Divider().color($r('app.color.border_default')).strokeWidth(1)

      Scroll() {
        Column({ space: 24 }) {
          // Title
          Column({ space: 8 }) {
            Text('任务标题 *').fontSize(14).fontColor($r('app.color.text_primary'))
            TextInput({ placeholder: '输入任务名称...' })
              .height(48)
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.border_input') })
              .onChange((val: string) => this.title = val)
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Description
          Column({ space: 8 }) {
            Text('任务描述').fontSize(14).fontColor($r('app.color.text_primary'))
            TextArea({ placeholder: '添加详细的背景信息或步骤...' })
              .height(120)
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.border_input') })
              .onChange((val: string) => this.description = val)
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Assignee
          Column({ space: 8 }) {
            Text('分配负责人').fontSize(14).fontColor($r('app.color.text_primary'))
            Select(this.assignees.map(a => ({ value: a } as SelectOption)))
              .value(this.assignee)
              .font({ size: 16 })
              .selectedOptionFont({ size: 16 })
              .optionFont({ size: 16 })
              .width('100%')
              .height(48)
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.border_input') })
              .onSelect((index: number, value: string) => {
                this.assignee = value;
              })
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Priority
          Column({ space: 8 }) {
            Text('优先级').fontSize(14).fontColor($r('app.color.text_primary'))
            Select(this.priorities.map(p => ({ value: p } as SelectOption)))
              .value(this.priority)
              .font({ size: 16 })
              .selectedOptionFont({ size: 16 })
              .optionFont({ size: 16 })
              .width('100%')
              .height(48)
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.border_input') })
              .onSelect((index: number, value: string) => {
                this.priority = value;
              })
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Status
          Column({ space: 8 }) {
            Text('任务状态').fontSize(14).fontColor($r('app.color.text_primary'))
            Select(this.statuses.map(s => ({ value: s } as SelectOption)))
              .value(this.status)
              .font({ size: 16 })
              .selectedOptionFont({ size: 16 })
              .optionFont({ size: 16 })
              .width('100%')
              .height(48)
              .backgroundColor($r('app.color.bg_card'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.border_input') })
              .onSelect((index: number, value: string) => {
                this.status = value;
              })
          }.alignItems(HorizontalAlign.Start).width('100%')

          // Due Date
          Column({ space: 8 }) {
            Text('截止日期').fontSize(14).fontColor($r('app.color.text_primary'))
            Row() {
              Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 12 })
              Text(this.dueDate).fontSize(16).fontColor(this.dueDate === 'mm/dd/yyyy' ? $r('app.color.text_tertiary') : $r('app.color.text_primary')).layoutWeight(1)
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor($r('app.color.bg_card'))
            .borderRadius(12)
            .border({ width: 1, color: $r('app.color.border_input') })
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

          Divider().color($r('app.color.border_default')).strokeWidth(1).margin({ top: 16, bottom: 16 })

          // Buttons
          Row({ space: 16 }) {
            Button('取消')
              .backgroundColor($r('app.color.bg_card'))
              .fontColor($r('app.color.text_secondary'))
              .border({ width: 1, color: $r('app.color.border_input') })
              .width(120)
              .height(44)
              .borderRadius(12)
              .onClick(() => router.back({ url: 'pages/Index' }))
            
            Button('保存任务')
              .backgroundColor($r('app.color.accent'))
              .fontColor($r('app.color.text_inverse'))
              .width(120)
              .height(44)
              .borderRadius(12)
              .onClick(() => this.saveTask())
          }.width('100%').justifyContent(FlexAlign.End)

        }.padding(24)
      }
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
  }

  async saveTask() {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '任务标题不能为空', duration: 2000 });
      return;
    }
    const newTask: Task = {
      id: this.isEdit ? this.editTaskId : Date.now().toString(),
      title: this.title,
      description: this.description,
      assignee: this.assignee === '选择团队成员' ? '未分配' : this.assignee,
      dueDate: this.dueDate === 'mm/dd/yyyy' ? '无' : this.dueDate,
      priority: this.priority,
      status: this.status
    };
    if (this.isEdit) {
      await TaskStore.getInstance().updateTask(newTask);
    } else {
      await TaskStore.getInstance().addTask(newTask);
    }
    router.back({ url: 'pages/Index' });
  }
}
