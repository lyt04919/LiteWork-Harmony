import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Task, TaskStore } from '../utils/TaskStore';

@Component
export struct TaskBoard {
  @StorageLink('globalTasks') tasks: Task[] = [];
  @State currentStatus: string = '待办';
  @State searchText: string = '';
  @State currentAssignee: string = '全部';

  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    this.loadTasks();
  }

  onPageShow() {
    this.loadTasks(); // reload when returned from CreateTask
  }

  async loadTasks() {
    this.tasks = await TaskStore.getInstance().getTasks();
    if (this.tasks.length === 0) {
      // Add mock tasks if empty for demonstration
      await TaskStore.getInstance().addTask({
        id: '1', title: '多智能体协作代码联调', description: '完成核心交互逻辑的测试...',
        assignee: '张伟', dueDate: '明天', priority: '高优先级', status: '待办'
      });
      await TaskStore.getInstance().addTask({
        id: '2', title: '数据库索引优化', description: '',
        assignee: '李娜', dueDate: '10月24日', priority: '普通', status: '待办'
      });
      this.tasks = await TaskStore.getInstance().getTasks();
    }
  }

  getFilteredTasks(): Task[] {
    return this.tasks.filter(t => 
      t.status === this.currentStatus && 
      (t.title.includes(this.searchText) || this.searchText === '') &&
      (this.currentAssignee === '全部' || t.assignee === this.currentAssignee)
    );
  }





  onItemDrop(event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean): void {
    if (!isSuccess) return;
    
    let filtered = this.getFilteredTasks();
    if (itemIndex < 0 || itemIndex >= filtered.length) return;
    let draggedTask = filtered[itemIndex];
    let originalDragIndex = this.tasks.findIndex(t => t.id === draggedTask.id);
    if (originalDragIndex === -1) return;

    this.tasks.splice(originalDragIndex, 1);

    if (insertIndex >= filtered.length) {
      let lastTask = filtered[filtered.length - 1];
      if (lastTask && lastTask.id !== draggedTask.id) {
         let lastIndex = this.tasks.findIndex(t => t.id === lastTask.id);
         this.tasks.splice(lastIndex + 1, 0, draggedTask);
      } else {
         this.tasks.push(draggedTask);
      }
    } else {
      let insertTask = filtered[insertIndex];
      let originalInsertIndex = this.tasks.findIndex(t => t.id === insertTask.id);
      if (originalInsertIndex !== -1) {
        this.tasks.splice(originalInsertIndex, 0, draggedTask);
      } else {
        this.tasks.push(draggedTask);
      }
    }
    
    TaskStore.getInstance().saveTasks(this.tasks);
  }

  async updateTaskStatus(task: Task, newStatus: string) {
    if (task.status === newStatus) return;
    task.status = newStatus;
    await TaskStore.getInstance().updateTask(task);
    this.loadTasks(); // refresh UI
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // Header
        Row() {
          Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 12 }) // placeholder
          Text('任务看板').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#0066FF').layoutWeight(1)
          Image($r('app.media.startIcon')).width(24).height(24).borderRadius(12) // profile icon
        }.width('100%').padding(16).alignItems(VerticalAlign.Center)

        // Filter Row
        Row({ space: 12 }) {
          TextInput({ placeholder: '搜索任务...' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#f2f4f7')
            .borderRadius(12)
            .onChange((value: string) => {
              this.searchText = value;
            })

          Select([
            { value: '全部' },
            { value: '张伟' },
            { value: '李娜' },
            { value: '王强' }
          ] as SelectOption[])
            .value(this.currentAssignee)
            .font({ size: 14 })
            .selectedOptionFont({ size: 14 })
            .optionFont({ size: 14 })
            .height(40)
            .backgroundColor('#f2f4f7')
            .borderRadius(12)
            .onSelect((index: number, value: string) => {
              if (value) {
                this.currentAssignee = value;
              }
            })
        }
        .width('90%')
        .margin({ bottom: 16 })

        // Tabs
        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          TabContent() {
            this.TaskList('待办')
          }.tabBar(this.TabBuilder('待办', 0))

          TabContent() {
            this.TaskList('进行中')
          }.tabBar(this.TabBuilder('进行中', 1))

          TabContent() {
            this.TaskList('已完成')
          }.tabBar(this.TabBuilder('已完成', 2))
        }
        .onChange((index: number) => {
          if (index === 0) this.currentStatus = '待办';
          else if (index === 1) this.currentStatus = '进行中';
          else this.currentStatus = '已完成';
        })
        .layoutWeight(1)
      }.width('100%').height('100%').backgroundColor('#F5F7FA')

      // FAB
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('+').fontSize(32).fontColor(Color.White).margin({ bottom: 4 })
      }
      .width(56).height(56)
      .backgroundColor('#0066FF')
      .margin({ right: 24, bottom: 24 })
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/CreateTask' });
      })
    }
  }

  @Builder TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.currentStatus === name ? '#1E293B' : '#64748B')
        .fontSize(16)
        .fontWeight(this.currentStatus === name ? FontWeight.Bold : FontWeight.Normal)
      if (this.currentStatus === name) {
        Divider().strokeWidth(2).color('#0066FF').width(20).margin({ top: 4 })
      }
    }.padding({ top: 12, bottom: 12 })
  }

  @Builder TaskList(status: string) {
    List({ space: 16 }) {
      ForEach(this.getFilteredTasks(), (item: Task, index: number) => {
        ListItem() {
          this.TaskCard(item)
        }
      }, (item: Task) => item.id)
    }
    .width('90%')
    .height('100%')
    .margin({ top: 16 })
    .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
      return this.TaskCard(this.getFilteredTasks()[itemIndex]);
    })
    .onItemDrop((event, itemIndex, insertIndex, isSuccess) => this.onItemDrop(event, itemIndex, insertIndex, isSuccess))
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
      }.width('100%').margin({ bottom: 8 })

      Text(task.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ bottom: 8 })
      if (task.description) {
        Text(task.description).fontSize(14).fontColor('#64748B').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 16 })
      }

      Row() {
        Text(task.assignee).fontSize(14).fontColor('#1E293B').backgroundColor('#e0e3e6').padding(6).borderRadius(12)
        Blank()
        Text(task.dueDate).fontSize(14).fontColor('#64748B')
      }.width('100%').margin({ top: 16 })

    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width: 1, color: '#E2E8F0' })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/CreateTask', params: { task: task } });
    })
  }
}
