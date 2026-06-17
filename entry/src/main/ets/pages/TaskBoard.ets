import router from "@ohos.router";
import promptAction from "@ohos.promptAction";
import { Task, TaskStore } from "../utils/TaskStore";

@Component
export struct TaskBoard {
  @StorageLink("globalTasks") tasks: Task[] = [];
  @State currentStatus: string = "待办";
  @State searchText: string = "";
  @State currentAssignee: string = "全部";
  @State private dragPreviewTitle: string = "";
  @State private dragPreviewPriority: string = "";
  @State private dragPreviewAssignee: string = "";
  @State private draggingItemId: string = "";

  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    this.loadTasks();
  }

  onPageShow() {
    this.loadTasks();
  }

  async loadTasks() {
    this.tasks = await TaskStore.getInstance().getTasks();
    if (this.tasks.length === 0) {
      await TaskStore.getInstance().addTask({
        id: "1", title: "多智能体协作代码联调", description: "完成核心交互逻辑的测试...",
        assignee: "张伟", dueDate: "明天", priority: "高优先级", status: "待办"
      });
      await TaskStore.getInstance().addTask({
        id: "2", title: "数据库索引优化", description: "",
        assignee: "李娜", dueDate: "10月24日", priority: "普通", status: "待办"
      });
      this.tasks = await TaskStore.getInstance().getTasks();
    }
  }

  getFilteredTasks(): Task[] {
    return this.tasks.filter(t =>
      t.status === this.currentStatus &&
      (t.title.includes(this.searchText) || this.searchText === "") &&
      (this.currentAssignee === "全部" || t.assignee === this.currentAssignee)
    );
  }

  // 拖拽排序核心
  performReorder(itemIndex: number, insertIndex: number): void {
    if (itemIndex === insertIndex) return;

    let indices: number[] = [];
    this.tasks.forEach((t, i) => {
      if (t.status === this.currentStatus) indices.push(i);
    });

    if (itemIndex < 0 || itemIndex >= indices.length) return;

    let dragIdx = indices[itemIndex];
    let dragged = this.tasks[dragIdx];
    this.tasks.splice(dragIdx, 1);

    indices = [];
    this.tasks.forEach((t, i) => {
      if (t.status === this.currentStatus) indices.push(i);
    });

    if (insertIndex > itemIndex) insertIndex--;

    let insertFullIdx: number;
    if (insertIndex <= 0) {
      insertFullIdx = indices.length > 0 ? indices[0] : this.tasks.length;
    } else if (insertIndex >= indices.length) {
      insertFullIdx = indices.length > 0 ? indices[indices.length - 1] + 1 : this.tasks.length;
    } else {
      insertFullIdx = indices[insertIndex];
    }

    this.tasks.splice(insertFullIdx, 0, dragged);
    TaskStore.getInstance().saveTasks(this.tasks);
  }

  clearDragState(): void {
    this.draggingItemId = "";
  }

  async updateTaskStatus(task: Task, newStatus: string) {
    if (task.status === newStatus) return;
    task.status = newStatus;
    await TaskStore.getInstance().updateTask(task);
    this.loadTasks();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text("\u2630").fontSize(22).fontColor($r("app.color.accent")).margin({ right: 12 })
          Text("任务看板").fontSize(24).fontWeight(FontWeight.Bold).fontColor($r("app.color.accent")).layoutWeight(1)
          Image($r("app.media.startIcon")).width(24).height(24).borderRadius(12)
        }.width("100%").padding(16).alignItems(VerticalAlign.Center)

        Row({ space: 12 }) {
          TextInput({ placeholder: "搜索任务..." })
            .layoutWeight(1)
            .height(40)
            .backgroundColor($r("app.color.bg_input"))
            .borderRadius(12)
            .onChange((value: string) => {
              this.searchText = value;
            })

          Select([
            { value: "全部" },
            { value: "张伟" },
            { value: "李娜" },
            { value: "王强" }
          ] as SelectOption[])
            .value(this.currentAssignee)
            .font({ size: 14 })
            .selectedOptionFont({ size: 14 })
            .optionFont({ size: 14 })
            .height(40)
            .backgroundColor($r("app.color.bg_input"))
            .borderRadius(12)
            .onSelect((index: number, value: string) => {
              if (value) {
                this.currentAssignee = value;
              }
            })
        }
        .width("90%")
        .margin({ bottom: 16 })

        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          TabContent() {
            this.TaskList("待办")
          }.tabBar(this.TabBuilder("待办", 0))

          TabContent() {
            this.TaskList("进行中")
          }.tabBar(this.TabBuilder("进行中", 1))

          TabContent() {
            this.TaskList("已完成")
          }.tabBar(this.TabBuilder("已完成", 2))
        }
        .onChange((index: number) => {
          if (index === 0) this.currentStatus = "待办";
          else if (index === 1) this.currentStatus = "进行中";
          else this.currentStatus = "已完成";
        })
        .layoutWeight(1)
      }.width("100%").height("100%").backgroundColor($r("app.color.bg_page"))

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text("+").fontSize(32).fontColor($r("app.color.text_inverse")).margin({ bottom: 4 })
      }
      .width(56).height(56)
      .backgroundColor($r("app.color.accent"))
      .margin({ right: 24, bottom: 24 })
      .shadow({ radius: 10, color: $r("app.color.shadow_fab"), offsetY: 4 })
      .onClick(() => {
        router.pushUrl({ url: "pages/CreateTask" }, router.RouterMode.Standard);
      })
    }
  }

  @Builder TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.currentStatus === name ? $r("app.color.text_primary") : $r("app.color.text_secondary"))
        .fontSize(16)
        .fontWeight(this.currentStatus === name ? FontWeight.Bold : FontWeight.Normal)
      if (this.currentStatus === name) {
        Divider().strokeWidth(2).color($r("app.color.accent")).width(20).margin({ top: 4 })
      }
    }.padding({ top: 12, bottom: 12 })
  }

  @Builder TaskList(status: string) {
    List({ space: 16 }) {
      ForEach(this.getFilteredTasks(), (item: Task) => {
        ListItem() {
          this.TaskCard(item)
        }
      }, (item: Task) => item.id)
    }
    .width("90%")
    .height("100%")
    .margin({ top: 16 })
    .edgeEffect(EdgeEffect.Spring)
    .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
      let task = this.getFilteredTasks()[itemIndex];
      if (task) {
        this.dragPreviewTitle = task.title;
        this.dragPreviewPriority = task.priority;
        this.dragPreviewAssignee = task.assignee;
        this.draggingItemId = task.id;
      }
      return this.dragPreviewCard;
    })
    .onItemDrop((event, itemIndex, insertIndex, isSuccess) => {
      this.clearDragState();
      if (!isSuccess) return;
      this.performReorder(itemIndex, insertIndex);
    })
  }

  // 拖拽预览卡片：左侧优先级色条 + 标题 + 负责人，放大 + 强阴影
  @Builder dragPreviewCard() {
    Row() {
      Column()
        .width(4)
        .height("100%")
        .backgroundColor(this.dragPreviewPriority === "高优先级" ? "#BA1A1A" : "#0054D6")
        .borderRadius(2)

      Column() {
        Text(this.dragPreviewTitle)
          .fontSize(14)
          .fontColor($r("app.color.text_primary"))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width("100%")
        Text(this.dragPreviewAssignee)
          .fontSize(12)
          .fontColor($r("app.color.text_secondary"))
          .margin({ top: 4 })
      }
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(230)
    .height(60)
    .backgroundColor($r("app.color.bg_card"))
    .borderRadius(10)
    .opacity(0.95)
    .scale({ x: 1.04, y: 1.04 })
    .shadow({ radius: 20, color: "#40000000", offsetY: 8 })
  }

  @Builder TaskCard(task: Task) {
    Column() {
      Row() {
        if (task.priority === "高优先级") {
          Text(task.priority).fontSize(12).fontColor($r("app.color.text_priority_high")).backgroundColor($r("app.color.bg_priority_high")).padding(4).borderRadius(4)
        } else {
          Text("普通").fontSize(12).fontColor($r("app.color.text_priority_normal")).backgroundColor($r("app.color.bg_priority_normal")).padding(4).borderRadius(4)
        }
        Blank()
      }.width("100%").margin({ bottom: 8 })

      Text(task.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor($r("app.color.text_primary")).margin({ bottom: 8 })
      if (task.description) {
        Text(task.description).fontSize(14).fontColor($r("app.color.text_secondary")).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 16 })
      }

      Row() {
        Text(task.assignee).fontSize(14).fontColor($r("app.color.text_primary")).backgroundColor($r("app.color.bg_assignee")).padding(6).borderRadius(12)
        Blank()
        Text(task.dueDate).fontSize(14).fontColor($r("app.color.text_secondary"))
      }.width("100%").margin({ top: 16 })

    }
    .width("100%")
    .padding(16)
    .backgroundColor($r("app.color.bg_card"))
    .borderRadius(12)
    .border({ width: 1, color: $r("app.color.border_default") })
    .shadow({ radius: 8, color: $r("app.color.shadow_card"), offsetY: 2 })
    .opacity(task.id === this.draggingItemId ? 0.35 : 1.0)
    .onClick(() => {
      router.pushUrl({ url: "pages/CreateTask", params: { task: task } }, router.RouterMode.Standard);
    })
  }
}

