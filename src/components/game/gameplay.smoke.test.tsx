import { describe, expect, it, vi } from "vitest";
import { render, fireEvent } from "@testing-library/react";
import { getPatternById } from "@/lib/patterns/catalog";
import { expectedEdgeKeys, parseNodeId } from "@/lib/game/geometry";
import { validatePattern } from "@/lib/game/validation";
import { KolamView } from "@/components/game/KolamView";
import { Button } from "@/components/ui/Button";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  useSearchParams: () => new URLSearchParams(),
}));

describe("gameplay smoke", () => {
  it("traces bindu by walking every expected edge and validates success", () => {
    const pattern = getPatternById("bindu")!;
    const segments = [...expectedEdgeKeys(pattern)].map((key) => {
      const [a, b] = key.split("|") as [string, string];
      return { from: parseNodeId(a), to: parseNodeId(b) };
    });
    const result = validatePattern(pattern, segments);
    expect(result.passed).toBe(true);
    expect(result.matchedEdges).toBe(result.expectedEdges);
  });

  it("renders a kolam board and a check control", () => {
    const pattern = getPatternById("kuttu")!;
    const { getByLabelText, getByText } = render(
      <>
        <KolamView pattern={pattern} showReference />
        <Button>Check</Button>
      </>,
    );
    expect(getByLabelText("Kuttu kolam")).toBeInTheDocument();
    expect(getByText("Check")).toBeInTheDocument();
    fireEvent.click(getByText("Check"));
  });
});
