"use client";

import type { ButtonHTMLAttributes, ReactNode } from "react";

export function IconButton({
  label,
  children,
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { label: string; children: ReactNode }) {
  return (
    <button
      aria-label={label}
      title={label}
      className={`inline-flex min-h-11 min-w-11 items-center justify-center rounded-full text-[13px] tracking-wide text-charcoal/80 hover:bg-charcoal/5 disabled:opacity-35 ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
