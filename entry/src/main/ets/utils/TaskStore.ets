import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export interface Task {
  id: string;
  title: string;
  description: string;
  assignee: string;
  dueDate: string;
  priority: string; // "高优先级", "中优先级", "低优先级"
  status: string; // "待办", "进行中", "已完成"
}

const PREF_NAME = 'TaskPreferences';
const TASK_KEY = 'TaskList';

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
      }).catch(err => {
        console.error('Failed to init preferences', err);
      });
    }
    await this.initPromise;
  }

  public async getTasks(): Promise<Task[]> {
    if (this.initPromise) await this.initPromise;
    if (!this.pref) return [];
    try {
      let tasksStr = await this.pref.get(TASK_KEY, '[]') as string;
      let tasks = JSON.parse(tasksStr) as Task[];
      AppStorage.SetOrCreate('globalTasks', tasks);
      return tasks;
    } catch (err) {
      console.error('Failed to get tasks', err);
      return [];
    }
  }

  public async saveTasks(tasks: Task[]): Promise<void> {
    if (this.initPromise) await this.initPromise;
    if (!this.pref) return;
    try {
      await this.pref.put(TASK_KEY, JSON.stringify(tasks));
      await this.pref.flush();
      AppStorage.SetOrCreate('globalTasks', tasks);
    } catch (err) {
      console.error('Failed to save tasks', err);
    }
  }

  public async addTask(task: Task): Promise<void> {
    let tasks = await this.getTasks();
    tasks.push(task);
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
