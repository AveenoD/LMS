"use client";

import React from "react";
import { cn } from "@/utils/cn";
import { ArrowRight } from "lucide-react";

type ButtonVariant = "primary" | "secondary" | "tertiary" | "text";
type ButtonSize = "sm" | "md" | "lg";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  withArrow?: boolean;
  href?: string;
  children: React.ReactNode;
}

const variantStyles: Record<ButtonVariant, string> = {
  primary:
    "bg-brass-gold text-white hover:bg-brass-gold/90 shadow-md hover:shadow-lg",
  secondary:
    "bg-white text-ink-green border-2 border-ink-green hover:bg-ink-green hover:text-white",
  tertiary:
    "bg-chalk-teal text-white hover:bg-chalk-teal/90 shadow-md hover:shadow-lg",
  text: "bg-transparent text-chalk-teal hover:text-brass-gold p-0",
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: "px-4 py-2 text-sm",
  md: "px-6 py-2.5 text-base",
  lg: "px-8 py-3 text-lg",
};

export default function Button({
  variant = "primary",
  size = "md",
  withArrow = false,
  href,
  children,
  className,
  ...props
}: ButtonProps) {
  const classes = cn(
    "inline-flex items-center justify-center gap-2 rounded-lg font-body font-semibold transition-all duration-300 cursor-pointer whitespace-nowrap",
    variant !== "text" && sizeStyles[size],
    variantStyles[variant],
    className
  );

  if (href) {
    return (
      <a href={href} className={classes}>
        {children}
        {withArrow && <ArrowRight className="w-4 h-4" />}
      </a>
    );
  }

  return (
    <button className={classes} {...props}>
      {children}
      {withArrow && (
        <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
      )}
    </button>
  );
}
