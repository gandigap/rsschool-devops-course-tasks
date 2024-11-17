import { showGreeting } from "./util";

describe('showGreeting', () => {
  it('должен корректно возвращать приветственное сообщение', () => {
    const name = 'Alice';
    const result = showGreeting(name);
    expect(result).toBe('Hello devops World! I am Alice');
  });

  it('должен корректно возвращать сообщение для другого имени', () => {
    const name = 'Bob';
    const result = showGreeting(name);
    expect(result).toBe('Hello devops World! I am Bob');
  });
});