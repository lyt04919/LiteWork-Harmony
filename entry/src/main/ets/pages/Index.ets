import { TaskBoard } from "./TaskBoard";
import { Profile } from "./Profile";
import { AIChat } from "./AIChat";
import { TaskStore } from "../utils/TaskStore";
import common from "@ohos.app.ability.common";

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    const context = getContext() as common.UIAbilityContext;
    TaskStore.getInstance().init(context);
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        TaskBoard()
      }.tabBar(this.TabBuilder("首页看板", 0, "\u2630"))

      TabContent() {
        AIChat()
      }.tabBar(this.TabBuilder("AI助理", 1, "\u2726"))

      TabContent() {
        Profile()
      }.tabBar(this.TabBuilder("我的", 2, "\u25CE"))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  @Builder TabBuilder(title: string, targetIndex: number, iconText: string) {
    Column() {
      Text(iconText)
        .fontSize(22)
        .fontColor(this.currentIndex === targetIndex ? $r("app.color.accent") : $r("app.color.tab_inactive"))
        .margin({ bottom: 2 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r("app.color.accent") : $r("app.color.tab_inactive"))
        .fontSize(12)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
    }.width("100%").height(56).justifyContent(FlexAlign.Center)
  }
}
