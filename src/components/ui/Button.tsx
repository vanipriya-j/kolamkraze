"use client";

import type { ButtonHTMLAttributes, ReactNode } from "react";

type Variant = "primary" | "ghost" | "quiet";

const styles: Record<Variant, string> = {
  primary:
    "bg-charcoal text-ivory hover:bg-ink disabled:opacity-40 min-h-12 px-6",
  ghost:
    "border border-charcoal/20 text-charcoal hover:border-charcoal/40 min-h-12 px-5",
  quiet: "text-charcoal/70 hover:text-charcoal min-h-11 px-3",
};

export function Button({
  variant = "primary",
  className = "",
  children,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
  children: ReactNode;
}) {
  return (
    <button
      className={`inline-flex items-center justify-center rounded-full text-[15px] tracking-wide transition-colors duration-200 ${styles[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
