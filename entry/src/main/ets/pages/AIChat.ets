import http from '@ohos.net.http';
import router from '@ohos.router';

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
    new ChatMessage('ai', '您好！我是您的智能专属客服助手。请问有什么我可以帮您的？您可以询问关于订单状态、产品使用说明或退换货政策等问题。')
  ];
  @State inputText: string = '';

  private scroller: Scroller = new Scroller();

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon')).width(24).height(24).margin({ right: 16 })
        Column() {
          Text('AI 客服助手').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1E293B')
          Text('在线').fontSize(12).fontColor('#64748B')
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Text('...').fontSize(24).fontColor('#64748B').fontWeight(FontWeight.Bold)
      }.width('100%').padding(16).backgroundColor(Color.White)
      
      Divider().color('#E2E8F0').strokeWidth(1)

      // Chat List
      Scroll(this.scroller) {
        Column({ space: 16 }) {
          Text('今天 10:24 AM').fontSize(12).fontColor('#94A3B8').backgroundColor('#F5F7FA').padding({ top: 4, bottom: 4, left: 12, right: 12 }).borderRadius(16).margin({ top: 16, bottom: 8 })

          ForEach(this.messages, (msg: ChatMessage) => {
            Row() {
              if (msg.role === 'ai') {
                Image($r('app.media.startIcon')).width(36).height(36).borderRadius(18).margin({ right: 12 })
                Text(msg.content)
                  .fontSize(16)
                  .fontColor('#1E293B')
                  .backgroundColor('#EDF2F7')
                  .padding(16)
                  .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 2, bottomRight: 12 })
                  .layoutWeight(1)
              } else {
                Text(msg.content)
                  .fontSize(16)
                  .fontColor(Color.White)
                  .backgroundColor('#0066FF')
                  .padding(16)
                  .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 12, bottomRight: 2 })
                  .layoutWeight(1)
              }
            }.width('100%').justifyContent(msg.role === 'ai' ? FlexAlign.Start : FlexAlign.End)
          })
        }.padding(16).width('100%')
      }.layoutWeight(1).align(Alignment.Top)

      // Input area
      Row() {
        Image($r('app.media.startIcon')).width(28).height(28).margin({ right: 12 })
        TextInput({ placeholder: '请输入问题...', text: this.inputText })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F7FA')
          .borderRadius(22)
          .border({ width: 1, color: '#CBD5E1' })
          .onChange((val) => this.inputText = val)
          .onSubmit(() => this.sendMessage())
        
        Button() {
          Text('发送').fontColor(Color.White).fontSize(14)
        }
        .width(44)
        .height(44)
        .backgroundColor('#0066FF')
        .borderRadius(22)
        .margin({ left: 12 })
        .onClick(() => this.sendMessage())
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid }) // top border conceptually
    }.width('100%').height('100%').backgroundColor('#FAFAFA')
  }

  sendMessage() {
    if (!this.inputText.trim()) return;
    this.messages.push(new ChatMessage('user', this.inputText));
    let question = this.inputText;
    this.inputText = '';
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);

    this.requestAIResponse(question);
  }

  async requestAIResponse(question: string) {
    let httpRequest = http.createHttp();
    const API_URL = 'https://api.openai.com/v1/chat/completions';
    const API_KEY = 'YOUR_API_KEY'; // TODO: Replace with your actual API key

    if (API_KEY === 'YOUR_API_KEY') {
       // fallback to mock if key is not provided
       setTimeout(() => {
          this.messages.push(new ChatMessage('ai', `好的，关于您说的"${question}"，我已经记录并会为您处理。（注：当前未配置真实API KEY，展示模拟回复）`));
          setTimeout(() => {
            this.scroller.scrollEdge(Edge.Bottom);
          }, 100);
        }, 1000);
        return;
    }

    try {
      let response = await httpRequest.request(API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${API_KEY}`
        },
        extraData: JSON.stringify(new AIRequestPayload('gpt-3.5-turbo', [new ChatMessage('user', question)])),
        readTimeout: 60000,
        connectTimeout: 60000
      });
      
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as AIResponse;
        let aiMessage = result.choices[0].message.content;
        this.messages.push(new ChatMessage('ai', aiMessage));
      } else {
        this.messages.push(new ChatMessage('ai', '抱歉，大模型请求失败了。请检查网络或API_KEY。'));
      }
    } catch (err) {
      this.messages.push(new ChatMessage('ai', '系统异常，大模型服务暂不可用。'));
    }
    
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }
}
