import http from "@ohos.net.http";
import router from "@ohos.router";
import { TaskStore, Task } from "../utils/TaskStore";
import common from "@ohos.app.ability.common";

export class ChatMessage {
  role: string;
  content: string;
  constructor(role: string, content: string) {
    this.role = role;
    this.content = content;
  }
}

interface AIResponseChoice {
  message: ChatMessage;
}

interface AIResponse {
  choices: AIResponseChoice[];
}

export class AIRequestPayload {
  model: string;
  messages: ChatMessage[];
  constructor(model: string, messages: ChatMessage[]) {
    this.model = model;
    this.messages = messages;
  }
}

@Entry
@Component
export struct AIChat {
  @State messages: ChatMessage[] = [
    new ChatMessage("assistant", "你好，我是 LiteAI，LiteWork 的内置智能助手。我可以帮你查看任务进度、分析工作负载、提供优先级建议，也可以聊聊团队协作。有什么需要？")
  ];
  @State inputText: string = "";
  @State isLoading: boolean = false;

  private scroller: Scroller = new Scroller();

  build() {
    Column() {
      // Header
      Row() {
        Image($r("app.media.startIcon")).width(24).height(24).margin({ right: 16 })
        Column() {
          Text("AI 助手 LiteAI").fontSize(20).fontWeight(FontWeight.Bold).fontColor($r("app.color.text_primary"))
          Text("在线").fontSize(12).fontColor($r("app.color.text_secondary"))
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Text("...").fontSize(24).fontColor($r("app.color.text_secondary")).fontWeight(FontWeight.Bold)
      }.width("100%").padding(16).backgroundColor($r("app.color.bg_card"))
      
      Divider().color($r("app.color.border_default")).strokeWidth(1)

      // Chat List
      Scroll(this.scroller) {
        Column({ space: 16 }) {
          Text("今天 10:24 AM").fontSize(12).fontColor($r("app.color.text_tertiary")).backgroundColor($r("app.color.bg_time_badge")).padding({ top: 4, bottom: 4, left: 12, right: 12 }).borderRadius(16).margin({ top: 16, bottom: 8 })

          ForEach(this.messages.filter(m => m.role !== "loading"), (msg: ChatMessage) => {
            Row() {
              if (msg.role === "assistant") {
                Image($r("app.media.startIcon")).width(36).height(36).borderRadius(18).margin({ right: 12 })
                Text(msg.content)
                  .fontSize(16)
                  .fontColor($r("app.color.text_primary"))
                  .backgroundColor($r("app.color.bg_ai_message"))
                  .padding(16)
                  .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 2, bottomRight: 12 })
                  .layoutWeight(1)
              } else {
                Text(msg.content)
                  .fontSize(16)
                  .fontColor($r("app.color.text_inverse"))
                  .backgroundColor($r("app.color.accent"))
                  .padding(16)
                  .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 12, bottomRight: 2 })
                  .layoutWeight(1)
              }
            }.width("100%").justifyContent(msg.role === "assistant" ? FlexAlign.Start : FlexAlign.End)
          })

          if (this.isLoading) {
            Row() {
              Image($r("app.media.startIcon")).width(36).height(36).borderRadius(18).margin({ right: 12 })
              Column() {
                Row({ space: 6 }) {
                  Image($r("app.media.startIcon")).width(16).height(16).opacity(0.4)
                  Text("AI 正在输入...").fontSize(14).fontColor($r("app.color.text_secondary"))
                }
              }
              .backgroundColor($r("app.color.bg_ai_message"))
              .borderRadius({ topLeft: 2, topRight: 12, bottomLeft: 12, bottomRight: 12 })
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            }.width("100%")
          }
        }.padding(16).width("100%")
      }.layoutWeight(1).align(Alignment.Top)

      // Input area
      Row() {
        Image($r("app.media.startIcon")).width(28).height(28).margin({ right: 12 })
        TextInput({ placeholder: "问 LiteAI 任何任务相关的问题...", text: this.inputText })
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r("app.color.bg_time_badge"))
          .borderRadius(22)
          .border({ width: 1, color: $r("app.color.border_input") })
          .onChange((val) => this.inputText = val)
          .onSubmit(() => this.sendMessage())
        
        Button() {
          Text("发送").fontColor($r("app.color.text_inverse")).fontSize(14)
        }
        .width(44)
        .height(44)
        .backgroundColor($r("app.color.accent"))
        .borderRadius(22)
        .margin({ left: 12 })
        .onClick(() => this.sendMessage())
      }
      .width("100%")
      .padding(16)
      .backgroundColor($r("app.color.bg_card"))
      .border({ width: 1, color: $r("app.color.border_default"), style: BorderStyle.Solid })
    }.width("100%").height("100%").backgroundColor($r("app.color.bg_aichat_page"))
  }

  sendMessage() {
    if (!this.inputText.trim()) return;
    let question = this.inputText;
    this.messages.push(new ChatMessage("user", question));
    this.inputText = "";
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);

    this.isLoading = true;
    this.requestAIResponse();
  }

  executeActions(text: string, appCtx: common.ApplicationContext) {
    if (text.includes("[DARK_MODE:ON]")) {
      appCtx.setColorMode(0);
      AppStorage.setOrCreate("darkMode", true);
    } else if (text.includes("[DARK_MODE:OFF]")) {
      appCtx.setColorMode(1);
      AppStorage.setOrCreate("darkMode", false);
    }
  }

  async buildAppContext(): Promise<string> {
    const tasks = await TaskStore.getInstance().getTasks();
    if (tasks.length === 0) {
      return `你是 LiteWork 任务管理应用的内置 AI 助手。你的名字叫 LiteAI。

应用功能：
- 任务看板：查看和管理所有任务，支持拖拽排序
- 新建/编辑任务：创建任务，设置标题、描述、负责人、优先级、截止日期
- 我的任务：查看分配给当前用户（张伟）的任务
- 深色模式：支持浅色/深色主题切换
- 系统设置：管理通知、缓存、账户

团队成员：张伟（高级产品经理）、李娜、王强、赵敏

当前没有待办任务。用户可以创建新任务。

请用友好、专业的语气回复，帮助用户管理任务和工作。

你可以执行以下操作：
- 切换深色模式：当用户要求切换主题时，回复中包含 [DARK_MODE:ON]（开启深色）或 [DARK_MODE:OFF]（关闭深色）。这些标记用户看不见，只会触发系统执行对应操作。`;
    }
    let summary = tasks.map(t =>
      `[${t.status}] ${t.title} - 负责人:${t.assignee} 优先级:${t.priority} 截止:${t.dueDate}`
    ).join("\n");
    return `你是 LiteWork 任务管理应用的内置 AI 助手。你的名字叫 LiteAI。

应用功能：
- 任务看板：查看和管理所有任务
- 新建/编辑任务：创建任务，设置标题、描述、负责人、优先级、截止日期
- 我的任务：查看分配给当前用户（张伟）的任务
- 深色模式：支持浅色/深色主题切换

团队成员：张伟（高级产品经理）、李娜、王强、赵敏

当前任务列表（共${tasks.length}项）：
${summary}

请用友好、专业的语气回复，基于以上信息帮用户管理任务和工作。`;
  }

  async requestAIResponse() {
    const appContext = await this.buildAppContext();
    const systemMessage = new ChatMessage("system", appContext);

    const contextMessages = [systemMessage, ...this.messages
      .filter(m => m.role !== "loading")
      .slice(-20)
      .map(m => new ChatMessage(m.role, m.content))];

    const appCtx = getContext().getApplicationContext();

    let httpRequest = http.createHttp();
    const API_URL = "https://apihub.agnes-ai.com/v1/chat/completions";
    const API_KEY = "sk-LCniHlX7GRlEvJDVulRnEkAAraUjOWXsq87VhOfM7N3VaKyn";

    try {
      let response = await httpRequest.request(API_URL, {
        method: http.RequestMethod.POST,
        header: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${API_KEY}`
        },
        extraData: JSON.stringify(new AIRequestPayload("agnes-2.0-flash", contextMessages)),
        readTimeout: 60000,
        connectTimeout: 60000
      });
      
      this.isLoading = false;

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as AIResponse;
        if (result.choices && result.choices.length > 0) {
          let aiMessage = result.choices[0].message.content;
          this.executeActions(aiMessage, appCtx);
          this.messages.push(new ChatMessage("assistant", aiMessage));
        } else {
          this.messages.push(new ChatMessage("assistant", "Agent 返回了空响应，请稍后重试。"));
        }
      } else {
        this.messages.push(new ChatMessage("assistant", `请求失败 (${response.responseCode})，请检查 API 配置。`));
      }
    } catch (err) {
      this.isLoading = false;
      this.messages.push(new ChatMessage("assistant", "网络异常，大模型服务暂不可用。请检查网络。"));
    }
    
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }
}
