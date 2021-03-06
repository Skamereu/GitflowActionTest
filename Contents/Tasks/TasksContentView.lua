-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Tasks.ContentView"                  ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
__Recyclable__ "SylingTracker_TasksContentView%d"
class "TasksContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    if data.quests then 
      local tasks = self:AcquireTasks()
      tasks:UpdateView(data.quests, updater)
    else 
      self:ReleaseTasks()
    end
  end

  function AcquireTasks(self)
    local content = self:GetChild("Content")
    local tasks = content:GetChild("Tasks")
    if not tasks then 
      tasks = TaskListView.Acquire()

      -- We need to keep the old name when we'll release it 
      self.__previousTasksName = tasks:GetName()

      tasks:SetParent(content)
      tasks:SetName("Tasks")

      -- It's important to style only when we have set its parent and its name
      if self.Tasks then 
        Style[tasks] = self.Tasks 
      end

      -- Register the vents 
      tasks.OnSizeChanged = tasks.OnSizeChanged + self.OnTasksSizeChanged

      self:AdjustHeight(true)
    end

    return tasks
  end

  function ReleaseTasks(self)
    local content = self:GetChild("Content")
    local tasks = content:GetChild("Tasks")
    if tasks then 
      -- Give its old name (generated by the recycle system)
      tasks:SetName(self.__previousTasksName)

      -- Unregister the events 
      tasks.OnSizeChanged = tasks.OnSizeChanged - self.OnTasksSizeChanged

      -- It's better to release it after the event has been unregistered for avoiding
      -- useless call 
      tasks:Release()

      self:AdjustHeight()
    end
  end

  function OnRelease(self)
    self:ReleaseTasks()

    self:Hide()
    self:ClearAllPoints()
    self:SetParent()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()

    self:AdjustHeight(true)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  -- property "PaddingBottom" {
  --   type    = Number,
  --   default = 10
  -- }

  -- The style used for tasks
  property "Tasks" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    -- Header = ContentHeader
    -- Tasks = TaskListView
  }
  function __ctor(self)
    -- -- Important ! We need the frame is instantly styled as this may affect 
    -- -- its height.
    -- self:InstantApplyStyle()

    -- self:SetClipsChildren(true)

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    -- local quests = self:GetChild("Tasks")

    -- quests.OnSizeChanged = function(...)
    --     self:AdjustHeight(true)
    -- end

    self.OnTasksSizeChanged = function() self:AdjustHeight(true) end

    self:SetClipsChildren(true)
  end
end)

-- Create the same thing for bonus tasks (also known as bonus objectives)
__Recyclable__ "SylingTracker_BonusTasksContentView%d"
class "BonusTasksContentView" { TasksContentView }


-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TasksContentView] = {
    Header = {
      height = 32,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },
      IconBadge = {
        backdropColor = { r = 0, g = 0, b = 0, a = 0},
        Icon = {
          atlas = AtlasType("QuestBonusObjective")
        }
      },

      Label = {
        text = TRACKER_HEADER_OBJECTIVE
      } 
    },

    Tasks = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }   
    }
  },

  [BonusTasksContentView] = {
    Header = {
      Label = {
        text = TRACKER_HEADER_BONUS_OBJECTIVES
      }
    }
  }
})
