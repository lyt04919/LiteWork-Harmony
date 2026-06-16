import { TaskBoard } from './TaskBoard';
import { Profile } from './Profile';
import { AIChat } from './AIChat';
import { TaskStore } from '../utils/TaskStore';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    // Initialize TaskStore
    const context = getContext(this) as common.UIAbilityContext;
    TaskStore.getInstance().init(context);
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        TaskBoard()
      }.tabBar(this.TabBuilder('首页看板', 0, $r('app.media.startIcon')))

      TabContent() {
        AIChat()
      }.tabBar(this.TabBuilder('AI助理', 1, $r('app.media.startIcon')))

      TabContent() {
        Profile()
      }.tabBar(this.TabBuilder('我的', 2, $r('app.media.startIcon')))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  @Builder TabBuilder(title: string, targetIndex: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === targetIndex ? '#0066FF' : '#94A3B8')
        .margin({ bottom: 4 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#0066FF' : '#94A3B8')
        .fontSize(12)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
    }.width('100%').height(56).justifyContent(FlexAlign.Center)
  }
}