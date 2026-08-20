import { describe, expect, it } from "vitest";
import { LocalProgressRepository, MemoryProgressRepository } from "./local-repository";
import { createDefaultProgress } from "./defaults";
import { STORAGE_KEY } from "./types";

describe("persistence", () => {
  it("round-trips progress through the memory repository", () => {
    const repo = new MemoryProgressRepository();
    const next = {
      ...createDefaultProgress(),
      completed: ["bindu"],
      stars: { bindu: 3 as const },
      muted: true,
      irl: ["bindu"],
    };
    repo.save(next);
    expect(repo.load().stars.bindu).toBe(3);
    expect(repo.load().muted).toBe(true);
    expect(repo.load().irl).toContain("bindu");
  });

  it("round-trips progress through localStorage", () => {
    window.localStorage.removeItem(STORAGE_KEY);
    const repo = new LocalProgressRepository();
    repo.save({
      ...createDefaultProgress(),
      completed: ["kuttu"],
      digitalCompletions: 1,
      streak: 4,
    });
    const loaded = new LocalProgressRepository().load();
    expect(loaded.completed).toEqual(["kuttu"]);
    expect(loaded.streak).toBe(4);
    expect(loaded.version).toBe(1);
  });
});
