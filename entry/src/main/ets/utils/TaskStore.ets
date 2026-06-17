import preferences from "@ohos.data.preferences";
import common from "@ohos.app.ability.common";

export interface Task {
  id: string;
  title: string;
  description: string;
  assignee: string;
  dueDate: string;
  priority: string;
  status: string;
}

const PREF_NAME = "TaskPreferences";
const TASK_KEY = "TaskList";

export class TaskStore {
  private static instance: TaskStore;
  private pref: preferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): TaskStore {
    if (!TaskStore.instance) {
      TaskStore.instance = new TaskStore();
    }
    return TaskStore.instance;
  }

  private initPromise: Promise<void> | null = null;

  public async init(context: common.UIAbilityContext): Promise<void> {
    if (!this.initPromise) {
      this.initPromise = preferences.getPreferences(context, PREF_NAME).then(pref => {
        this.pref = pref;
      }).catch((err: Error) => {
        console.error("Failed to init preferences", err);
      });
    }
    await this.initPromise;
  }

  public async getTasks(): Promise<Task[]> {
    if (this.initPromise) await this.initPromise;
    if (!this.pref) return [];
    try {
      let tasksStr = await this.pref.get(TASK_KEY, "[]") as string;
      let tasks = JSON.parse(tasksStr) as Task[];
      AppStorage.setOrCreate("globalTasks", [...tasks]);
      return tasks;
    } catch (err) {
      console.error("Failed to get tasks", err);
      return [];
    }
  }

  public async saveTasks(tasks: Task[]): Promise<void> {
    if (this.initPromise) await this.initPromise;
    if (!this.pref) return;
    try {
      await this.pref.put(TASK_KEY, JSON.stringify(tasks));
      await this.pref.flush();
      AppStorage.setOrCreate("globalTasks", [...tasks]);
    } catch (err) {
      console.error("Failed to save tasks", err);
    }
  }

  public async addTask(task: Task): Promise<void> {
    let tasks = await this.getTasks();
    // 高优先级任务插到最前，普通任务追加到末尾
    if (task.priority === "高优先级") {
      tasks.unshift(task);
    } else {
      tasks.push(task);
    }
    await this.saveTasks(tasks);
  }

  public async updateTask(updatedTask: Task): Promise<void> {
    let tasks = await this.getTasks();
    const index = tasks.findIndex(t => t.id === updatedTask.id);
    if (index !== -1) {
      tasks[index] = updatedTask;
      await this.saveTasks(tasks);
    }
  }

  public async deleteTask(id: string): Promise<void> {
    let tasks = await this.getTasks();
    tasks = tasks.filter(t => t.id !== id);
    await this.saveTasks(tasks);
  }
}
