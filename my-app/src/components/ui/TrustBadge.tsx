"use client";

import React from "react";
import { type LucideIcon } from "lucide-react";
import { cn } from "@/utils/cn";

interface TrustBadgeProps {
  icon: LucideIcon;
  title: string;
  subtitle: string;
  className?: string;
}

export default function TrustBadge({
  icon: Icon,
  title,
  subtitle,
  className,
}: TrustBadgeProps) {
  return (
    <div
      className={cn(
        "flex items-center gap-3 px-4 py-3",
        className
      )}
    >
      <div className="w-10 h-10 rounded-full bg-chalk-teal/10 flex items-center justify-center flex-shrink-0">
        <Icon className="w-5 h-5 text-chalk-teal" />
      </div>
      <div>
        <p className="text-sm font-body font-semibold text-ink-green">
          {title}
        </p>
        <p className="text-xs text-ink-green/60 font-body">{subtitle}</p>
      </div>
    </div>
  );
}
