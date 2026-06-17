import router from "@ohos.router";
import promptAction from "@ohos.promptAction";
import { Task } from "../utils/TaskStore";

@Component
export struct Profile {
  @StorageLink("globalTasks") @Watch("onTasksChange") tasks: Task[] = [];
  @State completedCount: number = 0;
  @State totalCount: number = 0;
  @State completionRate: number = 0;
  private currentUser: string = "张伟";

  onTasksChange() {
    // 只统计分配给当前用户的任务
    let myTasks = (this.tasks || []).filter(t => t.assignee === this.currentUser);
    this.totalCount = myTasks.length;
    this.completedCount = myTasks.filter(t => t.status === "已完成").length;
    this.completionRate = this.totalCount === 0 ? 0 : Math.round((this.completedCount / this.totalCount) * 100);
  }

  aboutToAppear() {
    this.onTasksChange();
  }

  build() {
    Scroll() {
      Column() {
        // Header profile
        Column({ space: 8 }) {
          Image($r("app.media.startIcon"))
            .width(80)
            .height(80)
            .borderRadius(40)
            .margin({ top: 40 })
            .border({ width: 2, color: $r("app.color.accent") })
          Text(this.currentUser).fontSize(24).fontWeight(FontWeight.Bold).fontColor($r("app.color.text_primary"))
          Text("高级产品经理").fontSize(14).fontColor($r("app.color.text_secondary"))
        }.width("100%").alignItems(HorizontalAlign.Center)

        // Ring Chart Card — 仅统计当前用户的任务
        Column() {
          Text("我的任务完成度").fontSize(16).fontColor($r("app.color.text_primary")).margin({ bottom: 24 }).width("100%").textAlign(TextAlign.Start)

          Stack() {
            DataPanel({ values: [this.completedCount], max: this.totalCount === 0 ? 1 : this.totalCount, type: DataPanelType.Circle })
              .width(160)
              .height(160)

            Column() {
              Text(`${this.completionRate}%`).fontSize(36).fontWeight(FontWeight.Bold).fontColor($r("app.color.accent"))
              Text(`已完成 ${this.completedCount}/${this.totalCount}`).fontSize(12).fontColor($r("app.color.text_secondary")).margin({ top: 4 })
            }
          }
        }
        .width("90%")
        .padding(24)
        .margin({ top: 32, bottom: 24 })
        .backgroundColor($r("app.color.bg_card"))
        .borderRadius(16)
        .shadow({ radius: 10, color: $r("app.color.shadow_card"), offsetY: 4 })

        // Settings List
        Column({ space: 16 }) {
          this.SettingItem("我的任务", $r("app.media.startIcon"), "", () => {
            router.pushUrl({ url: "pages/MyTasks" }, router.RouterMode.Standard)
          })
          this.SettingItem("系统设置", $r("app.media.startIcon"), "", () => {
            router.pushUrl({ url: "pages/Settings" }, router.RouterMode.Standard)
          })
        }.width("90%")
      }.width("100%")
    }.width("100%").height("100%").backgroundColor($r("app.color.bg_page")).scrollable(ScrollDirection.Vertical)
  }

  @Builder SettingItem(title: string, icon: Resource, subtitle?: string, action?: () => void) {
    Row() {
      Image(icon).width(40).height(40).borderRadius(8).backgroundColor($r("app.color.bg_avatar_icon")).padding(8).margin({ right: 16 })
      Column() {
        Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r("app.color.text_primary"))
        if (subtitle) {
          Text(subtitle).fontSize(12).fontColor($r("app.color.accent")).margin({ top: 4 })
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text(">").fontSize(18).fontColor($r("app.color.text_tertiary"))
    }
    .width("100%")
    .padding(16)
    .backgroundColor($r("app.color.bg_card"))
    .borderRadius(12)
    .shadow({ radius: 4, color: $r("app.color.shadow_card"), offsetY: 2 })
    .border({ width: 1, color: $r("app.color.border_default") })
    .onClick(() => {
      if (action) {
        action();
      }
    })
  }
}
