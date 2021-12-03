import numpy as np
import tkinter as tk
from enum import Enum
import matplotlib.pyplot as plt

agentType = Enum('type', 'S I R')
HEIGHT = 500
WIDTH = 500

L = 100
AGENTS = 1000
ID_it = 0
SIM_SPEED = 10
BETA = 0.3
GAMMA = 0.01


class Agent():
    def __init__(self, initialPos, ID=None):
        if ID is None:
            global ID_it
            self.ID = ID_it
            ID_it += 1

        self.pos = initialPos
        self.type = agentType.S

    def getPos(self):
        return self.pos


class SIRModel():
    def __init__(self, num_Agents, length):
        self.length = length
        self.agents = []
        self.num_Agents = num_Agents
        self.createAgents(num_Agents)
        self.d = 0.8
        self.infectRandomAgents(10)
        self.beta = BETA
        self.gamma = GAMMA
        self.stat = {'t': [], 'numS': [], 'numI': [], 'numR': []}
        self.iter = 0
        self.done = False

    def infectRandomAgents(self, num):
        agents = self.agents.copy()
        np.random.shuffle(agents)

        if num < len(agents):
            agentsToInfect = agents[:num]
        else:
            agentsToInfect = agents

        for agent in agentsToInfect:
            agent.type = agentType.I

    def statistics(self):
        numS = 0
        numI = 0
        numR = 0

        for agent in self.agents:
            if agent.type is agentType.S:
                numS += 1
            elif agent.type is agentType.I:
                numI += 1
            elif agent.type is agentType.R:
                numR += 1

        # done if no infected left
        if numI == 0:
            self.done = True

        self.stat['t'].append(self.iter)
        self.stat['numS'].append(numS)
        self.stat['numI'].append(numI)
        self.stat['numR'].append(numR)

    def getCurrentStats(self):
        currS = self.stat['numS'][-1]
        currI = self.stat['numI'][-1]
        currR = self.stat['numR'][-1]
        currT = self.stat['t'][-1]

        return {'t': currT, 'numS': currS, 'numI': currI, 'numR': currR}

    def createAgents(self, amount):
        for _ in range(amount):
            position = np.random.randint(0, self.length, size=(2))
            agent = Agent(position)
            self.agents.append(agent)

    def getAgents(self):
        return self.agents

    # 20.7
    def moveAgents(self):
        for agent in self.agents:
            random = np.random.rand()

            if random < self.d:
                randomDir = np.random.randint(0, 4)

                if randomDir == 0:
                    agent.pos[0] += 1
                elif randomDir == 1:
                    agent.pos[0] -= 1
                elif randomDir == 2:
                    agent.pos[1] += 1
                elif randomDir == 3:
                    agent.pos[1] -= 1

                if agent.pos[0] >= self.length:
                    agent.pos[0] -= self.length
                elif agent.pos[0] < 0:
                    agent.pos[0] += self.length

                if agent.pos[1] >= self.length:
                    agent.pos[1] -= self.length
                elif agent.pos[1] < 0:
                    agent.pos[1] += self.length

    def getAgentById(self, ID):
        for agent in self.agents:
            if agent.ID == ID:
                return agent

    def checkRecovery(self):
        for agent in self.agents:
            if agent.type is agentType.I:
                if np.random.rand() < self.gamma:
                    agent.type = agentType.R

    def getAgentsAtPos(self, pos):
        agentsAtPos = []
        for agent in self.agents:
            if agent.pos[0] == pos[0] and agent.pos[1] == pos[1]:
                agentsAtPos.append(agent)

        return agentsAtPos

    # 78.1 %
    def checkInfection(self):
        positions = np.array([agent.pos for agent in self.agents])

        u, c = np.unique(positions, axis=0, return_counts=True)
        dup = u[c > 1]

        for d in dup:
            agents = self.getAgentsAtPos(d)

            types = [agent.type for agent in agents]

            if agentType.I in types:
                # Spread
                if np.random.rand() < self.beta:
                    for agent in agents:
                        if agent.type is agentType.S:
                            agent.type = agentType.I

    def isDone(self):
        return self.done

    def update(self):
        self.iter += 1

        self.moveAgents()
        self.checkInfection()
        self.checkRecovery()
        self.statistics()


class Window(tk.Frame):
    def __init__(self, master):
        super().__init__(master)
        self.master = master
        self.agentOvals = dict()
        self.shouldUpdate = True

        master.title("Disease Spreading")
        master.geometry("500x500")

        self.canvas = tk.Canvas(master, bg="black", height=HEIGHT,
                                width=WIDTH)

        self.pack(fill="both", expand=True)

        modelSize = L
        self.model = SIRModel(AGENTS, modelSize)

        self.gridSize = WIDTH / modelSize

        self.createAgentOvals(self.canvas)
        self.after(0, lambda: self.loop())

    def getCanvasCoordinates(self, gridCoords):
        return gridCoords * self.gridSize

    def createAgentOvals(self, canvas):
        agents = self.model.agents

        for agent in agents:
            position = self.getCanvasCoordinates(agent.pos)
            color = self.getColor(agent)
            oval = canvas.create_oval((position[0],
                                       position[1]),
                                      (position[0] + self.gridSize,
                                       position[1] + self.gridSize),
                                      fill=color, outline=color)

            self.agentOvals[agent.ID] = [position, oval, color]

    def updateOvals(self):
        # print(self.agentOvals)
        for agent in self.model.agents:
            self.agentOvals[agent.ID][0] = \
                self.getCanvasCoordinates(agent.pos)
            self.agentOvals[agent.ID][2] = self.getColor(agent)

    def getColor(self, agent):
        if agent.type is agentType.S:
            color = 'royalblue'
        elif agent.type is agentType.I:
            color = 'red'
        else:
            color = 'green3'
        return color

    def checkIfDone(self):
        if self.model.isDone():
            self.shouldUpdate = False

            stats = self.model.stat

            fig, ax = plt.subplots()
            ax.plot(stats['t'], stats['numS'], color='tab:blue',
                    label='Susceptible')
            ax.plot(stats['t'], stats['numI'], color='tab:red',
                    label='Infected')
            ax.plot(stats['t'], stats['numR'], color='tab:green',
                    label='Recovered')
            ax.legend()
            ax.set_xlabel('Time step')
            ax.set_ylabel('Number of agents')
            ax.set_title(
                f"Simulation with beta: {self.model.beta}, gamma: {self.model.gamma}")

            plt.show()

    def loop(self):
        # print("Updating...")

        # 56.7 %
        if self.shouldUpdate:
            self.checkIfDone()

            self.model.update()

            # update ovals
            # 6.5 %
            self.updateOvals()

        # 36.8 %
            self.render()
        self.after(SIM_SPEED, lambda: self.loop())

    def render(self):
        for ovalId in self.agentOvals:
            oval = self.agentOvals.get(ovalId, None)
            if oval is not None:
                self.canvas.moveto(oval[1], oval[0][0], oval[0][1])
                self.canvas.itemconfigure(oval[1], fill=oval[2],
                                          outline=oval[2])
                self.canvas.pack()


if __name__ == "__main__":
    print("Running simulation..")
    agent = Agent(0, [0, 0])

    root = tk.Tk()

    window = Window(root)

    window.mainloop()
