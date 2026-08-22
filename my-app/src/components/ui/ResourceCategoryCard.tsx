import React from "react";
import { type LucideIcon } from "lucide-react";

interface ResourceCategoryCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
}

export default function ResourceCategoryCard({
  icon: Icon,
  title,
  description,
}: ResourceCategoryCardProps) {
  return (
    <div className="group bg-white rounded-2xl p-6 border border-paper shadow-sm hover:shadow-card-hover transition-all duration-300 flex flex-col items-center text-center cursor-pointer">
      <div className="w-14 h-14 rounded-full bg-paper flex items-center justify-center text-ink-green group-hover:bg-chalk-teal group-hover:text-white transition-colors mb-4">
        <Icon className="w-6 h-6" />
      </div>
      <h3 className="text-lg font-display font-bold text-ink-green mb-2 group-hover:text-chalk-teal transition-colors">
        {title}
      </h3>
      <p className="text-ink-green/70 text-sm font-body leading-relaxed">
        {description}
      </p>
    </div>
  );
}
